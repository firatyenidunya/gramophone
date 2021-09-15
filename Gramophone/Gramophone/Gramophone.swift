//
//  Gramophone.swift
//  Gramophone
//
//  Created by Firat Yenidunya on 11.09.2021.
//  Copyright © 2021 com.gramophone.firatyenidunya. All rights reserved.
//

import Foundation
import AVFoundation

open class Gramophone: NSObject, GramophoneProtocol {
    public weak var delegate: GramophoneDelegate?
    public private(set) var gramophoneItems: [GramophoneItem] = []
    private var player: Player
    private var playingItemIndex: Int = 0

    public private(set) var state: GramophoneState = .unknown {
        didSet {
            delegate?.didStateChange(self, to: state)
        }
    }

    public var index: Int {
        return playingItemIndex
    }

    override public init() {
        self.player = Player()
        super.init()
        player.delegate = self
    }

    public func play() {
        if state == .paused {
            player.play()
            state = .playing
            return
        }

        if let item = gramophoneItems.element(at: playingItemIndex) {
            player.play(with: item.url)
            state = .playing
            delegate?.didItemPlay(self, at: playingItemIndex)
            return
        }

        if playingItemIndex >= gramophoneItems.count {
            playingItemIndex = 0
            play()
            return
        }

        if playingItemIndex < 0 {
            let lastIndexOfGramophoneItems = gramophoneItems.count - 1
            playingItemIndex = lastIndexOfGramophoneItems
            play()
            return
        }
    }

    private func playAt(index: Int) {
        playingItemIndex = index
        state = .loading
        play()
    }

    @discardableResult
    public func play(at index: Int) -> Bool {
        if index > gramophoneItems.count - 1 || index < 0 { return false }
        playAt(index: index)
        return true
    }

    public func playNext() {
        playAt(index: playingItemIndex + 1)
    }

    public func playPreviously() {
        playAt(index: playingItemIndex - 1)
    }

    public func pause() {
        player.pause()
        state = .paused
    }

    public func add(gramophoneItem: GramophoneItem) {
        gramophoneItems.append(gramophoneItem)
    }

    public func add(gramophoneItem: GramophoneItem, to index: Int) {
        gramophoneItems.insert(gramophoneItem, at: index)
    }

    public func add(gramophoneItems: [GramophoneItem]) {
        self.gramophoneItems.append(contentsOf: gramophoneItems)
    }

    @discardableResult
    public func removeItem(at index: Int) -> Bool {
        if !gramophoneItems.isEmpty && gramophoneItems.count > index {
            if playingItemIndex == index {
                playNext()
            }
            gramophoneItems.remove(at: index)
            return true
        }
        return false
    }

    public func removeAll() {
        if state == .playing {
            pause()
            player.removeItem()
        }
        gramophoneItems = []
    }
}

extension Gramophone: PlayerDelegate {
    func didTimeProgressChange(time: Time) {
        delegate?.didTimeProgressChange(self, time: time)
    }
}
