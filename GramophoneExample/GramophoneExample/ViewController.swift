//
//  ViewController.swift
//  GramophoneExample
//
//  Created by Firat Yenidunya on 17.06.2020.
//  Copyright © 2020 com.gramophone.firatyenidunya. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController, GramophoneDelegate {
    private var gramophone: GramophoneProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        gramophone = Gramophone()
        gramophone.delegate = self
        gramophone.add(gramophoneItems: [GramophoneItem(url: URL(string: "https://s3.amazonaws.com/kargopolov/kukushka.mp3")!,
                                                        title: "First Song",
                                                        duration: 350,
                                                        album: "First Album",
                                                        artist: "First Artist",
                                                        artwork: nil),
                                         GramophoneItem(url: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")!,
                                                        title: "Second Song",
                                                        duration: 350,
                                                        album: "First Album",
                                                        artist: "First Artist",
                                                        artwork: nil),
                                         GramophoneItem(url: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3")!,
                                                        title: "Third Song",
                                                        duration: 350,
                                                        album: "First Album",
                                                        artist: "First Artist",
                                                        artwork: nil)])
        gramophone.play()
    }

    func didStateChange(_ gramophone: Gramophone, to state: GramophoneState) {
        print(state)
    }

    func didItemPlay(_ gramophone: Gramophone, at index: Int) {
    }
}

@objc enum GramophoneState: Int, CustomStringConvertible {
    case unknown
    case playing
    case paused
    case loading
    case failed

    var description: String {
        switch self {
            case .playing:
                return "PLAYING"
            case .paused:
                return "PAUSED"
            case .loading:
                return "LOADING"
            case .failed:
                return "FAILED"
            case .unknown:
                return "UNKNOWN"
        }
    }
}

@objc protocol GramophoneDelegate: class {
    @objc optional func didStateChange(_ gramophone: Gramophone, to state: GramophoneState)
    @objc optional func didItemPlay(_ gramophone: Gramophone, at index: Int)
}

protocol GramophoneProtocol {
    var delegate: GramophoneDelegate? { get set }
    var gramophoneItems: [GramophoneItem] { get }
    var state: GramophoneState { get }

    func play()
    func play(at index: Int)
    func playNext()
    func playPreviously()

    func pause()

    func add(gramophoneItems: [GramophoneItem])
    func add(gramophoneItem: GramophoneItem)
    func add(gramophoneItem: GramophoneItem, to index: Int)

    func removeItem(at index: Int) -> Bool
    func removeAll()
}

class Gramophone: NSObject, GramophoneProtocol {
    weak var delegate: GramophoneDelegate?

    private(set) var gramophoneItems: [GramophoneItem] = []
    private var player: Player
    private var playingItemIndex: Int = 0

    private(set) var state: GramophoneState = .unknown {
        didSet {
            delegate?.didStateChange?(self, to: state)
        }
    }

    override init() {
        self.player = Player()
        super.init()

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print(error.localizedDescription) }

        setupRemoteCommandCenter()
    }

    func play() {
        if state == .paused {
            player.play()
            state = .playing
            return
        }

        if let item = gramophoneItems.element(at: playingItemIndex) {
            player.play(with: item.url)
            setupNowPlaying(with: item)
            state = .playing
            delegate?.didItemPlay?(self, at: playingItemIndex)
        }

        if playingItemIndex >= gramophoneItems.count {
            playingItemIndex = 0
            play()
        }

        if playingItemIndex < 0 {
            let lastIndexOfGramophoneItems = gramophoneItems.count - 1
            playingItemIndex = lastIndexOfGramophoneItems
            play()
        }
    }

    func play(at index: Int) {
        playingItemIndex = index
        play()
    }

    func playNext() {
        play(at: playingItemIndex + 1)
    }

    func playPreviously() {
        play(at: playingItemIndex - 1)
    }

    func pause() {
        player.pause()
        state = .paused
    }

    func add(gramophoneItem: GramophoneItem) {
        gramophoneItems.append(gramophoneItem)
    }

    func add(gramophoneItem: GramophoneItem, to index: Int) {
        gramophoneItems.insert(gramophoneItem, at: index)
    }

    func add(gramophoneItems: [GramophoneItem]) {
        self.gramophoneItems.append(contentsOf: gramophoneItems)
    }

    @discardableResult
    func removeItem(at index: Int) -> Bool {
        if !gramophoneItems.isEmpty && gramophoneItems.count > index {
            gramophoneItems.remove(at: index)
            return true
        }
        return false
    }

    func removeAll() {
        gramophoneItems.removeAll()
    }

    func setupNowPlaying(with nowPlayingItem: GramophoneItem) {
        var nowPlayingInfo: [String: Any] = [:]

        nowPlayingInfo[MPMediaItemPropertyTitle] = nowPlayingItem.title

        if let image = nowPlayingItem.artwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = nowPlayingItem.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [unowned self] event in
            self.play()
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            self.pause()
            return .success
        }

        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.playNext()
            return .success
        }

        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.playPreviously()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                self.player.seek(to: CMTimeMakeWithSeconds(event.positionTime, preferredTimescale: 1000000))
                return .success
            }
            return .commandFailed
        }
    }
}

private class Player {
    var player: AVPlayer!

    init() {
        player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
    }

    func play(with url: URL) {
        let playerItem = AVPlayerItem(url: url)

        self.player.replaceCurrentItem(with: playerItem)
        self.player.play()
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()

    }

    func seek(to time: CMTime) {
        player.seek(to: time)
    }
}

struct GramophoneItem {
    public var url: URL
    public var title: String?
    public var duration: Double?
    public var album: String?
    public var artist: String?
    public var artwork: UIImage?

    init(url: URL,
         title: String? = nil,
         duration: Double? = nil,
         album: String? = nil,
         artist: String? = nil,
         artwork: UIImage? = nil) {
        self.url = url
        self.title = title
        self.duration = duration
        self.album = album
        self.artist = artist
        self.artwork = artwork
    }
}

extension RandomAccessCollection {
    func element(at index: Index) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        return self[index]
    }
}
