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
    var gramaphoneState: GramophoneState = .paused

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        gramophone.loop = false
    }

    @IBAction func previousOnClick(_ sender: Any) {
        gramophone.playPreviously()
    }

    @IBAction func nextOnClick(_ sender: Any) {
        gramophone.playNext()
    }

    @IBAction func pauseOnClick(_ sender: Any) {
        if gramaphoneState == .paused {
            gramophone.play()
            return
        }

        if gramaphoneState == .playing {
            gramophone.pause()
            return
        }
    }

    func didStateChange(_ gramophone: Gramophone, to state: GramophoneState) {
        print(state)
        gramaphoneState = state
    }

    func didItemPlay(_ gramophone: Gramophone, at index: Int) {
        print(index)
    }
}

enum GramophoneState: Int, CustomStringConvertible {
    case playing
    case paused
    case loading
    case failed
    case unknown

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

protocol GramophoneDelegate: AnyObject {
    func didStateChange(_ gramophone: Gramophone, to state: GramophoneState)
    func didItemPlay(_ gramophone: Gramophone, at index: Int)
}

extension GramophoneDelegate {
    func didStateChange(_ gramophone: Gramophone, to state: GramophoneState) { }
    func didItemPlay(_ gramophone: Gramophone, at index: Int) { }
}

protocol GramophoneProtocol {
    var delegate: GramophoneDelegate? { get set }
    var gramophoneItems: [GramophoneItem] { get }
    var state: GramophoneState { get }

    /// Set it to true if you want your playlist plays as loop.
    /// Set it to false if you want your playlist pause when last audio played.
    /// Default value of loop is true.
    var loop: Bool { get set }

    func play()
    func play(at index: Int)
    func playNext()
    func playPreviously()

    func pause()

    func add(gramophoneItems: [GramophoneItem])
    func add(gramophoneItem: GramophoneItem)
    func add(gramophoneItem: GramophoneItem, to index: Int)

    /// Removes item from given index.
    /// If remove operation is failed returns false otherwise returns true.
    /// If removed item is playing at the time, automatically plays next audio.
    @discardableResult
    func removeItem(at index: Int) -> Bool

    /// Removes all items.
    /// Pauses player if it is playing.
    /// - Complexity: O(1)
    func removeAll()
}

class Gramophone: NSObject, GramophoneProtocol {
    weak var delegate: GramophoneDelegate?

    private(set) var gramophoneItems: [GramophoneItem] = []
    private var player: Player
    private var playingItemIndex: Int = 0

    private(set) var state: GramophoneState = .unknown {
        didSet {
            delegate?.didStateChange(self, to: state)
        }
    }

    var loop: Bool = true {
        didSet {
            isLoopActive = loop
        }
    }
    private var isLoopActive: Bool = true

    override init() {
        self.player = Player()
        super.init()

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
            delegate?.didItemPlay(self, at: playingItemIndex)
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
        player.pause()
        play(at: playingItemIndex + 1)
    }

    func playPreviously() {
        player.pause()
        play(at: playingItemIndex - 1)
    }

    func pause() {
        player.pause()
        state = .paused
    }

    /// Adds item to end of the list.
    func add(gramophoneItem: GramophoneItem) {
        gramophoneItems.append(gramophoneItem)
    }

    /// Adds item to given index.
    func add(gramophoneItem: GramophoneItem, to index: Int) {
        gramophoneItems.insert(gramophoneItem, at: index)
    }

    /// Adds given gramophone items to end of the current list.
    func add(gramophoneItems: [GramophoneItem]) {
        self.gramophoneItems.append(contentsOf: gramophoneItems)
    }

    /// Removes item from given index.
    /// If operation is failed returns false.
    /// If operation is successful returns true.
    /// If removed item is playing at the time automatically plays next audio.
    @discardableResult
    func removeItem(at index: Int) -> Bool {
        if !gramophoneItems.isEmpty && gramophoneItems.count > index {
            if playingItemIndex == index {
                playNext()
            }
            gramophoneItems.remove(at: index)
            return true
        }
        return false
    }

    /// Removes all items.
    /// Pauses player if it is playing.
    /// - Complexity: O(1)
    func removeAll() {
        if state == .playing {
            pause()
            player.removeItem()
        }
        gramophoneItems = []
    }

    private func setupNowPlaying(with nowPlayingItem: GramophoneItem) {
        var nowPlayingInfo: [String: Any] = [:]

        nowPlayingInfo[MPMediaItemPropertyTitle] = nowPlayingItem.title

        if let image = nowPlayingItem.artwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }

        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = nowPlayingItem.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        
        MPNowPlayingInfoCenter.default().playbackState = .playing
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.play()
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.pause()
            return .success
        }

        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.playNext()
            return .success
        }

        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.playPreviously()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget {[weak self] event in
            guard let self = self else { return .commandFailed }
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                self.player.seek(to: CMTimeMakeWithSeconds(event.positionTime, preferredTimescale: 1000000))
                return .success
            }
            return .commandFailed
        }
    }
}

private class Player {
    var player: AVPlayer

    init() {
        player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = true
    }

    func play(with url: URL) {
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        play()
    }

    func play() {
        player.play()
    }

    func play(at currentTime: Double) {
        player.seek(to: CMTime(value: CMTimeValue(currentTime), timescale: 1000000))
    }

    func pause() {
        player.pause()
    }

    func seek(to time: CMTime) {
        player.seek(to: time)
    }

    func removeItem() {
        player.replaceCurrentItem(with: nil)
    }

    func currentTime() -> Double {
        return Double(CMTimeGetSeconds(player.currentTime()))
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
