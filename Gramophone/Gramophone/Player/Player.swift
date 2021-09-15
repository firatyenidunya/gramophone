//
//  Player.swift
//  Gramophone
//
//  Created by Firat Yenidunya on 11.09.2021.
//  Copyright © 2021 com.gramophone.firatyenidunya. All rights reserved.
//

import Foundation
import MediaPlayer

protocol PlayerDelegate: AnyObject {
    func didTimeProgressChange(time: Time)
}

class Player {
    var player: AVPlayer
    weak var delegate: PlayerDelegate?

    init() {
        player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = true
        configurePlayerTimeObserver()
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

    private func configurePlayerTimeObserver() {
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1),
                                       queue: .main) { [weak self] (time) in
            guard let self = self else { return }

            if let currentItem = self.player.currentItem, currentItem.status == .readyToPlay {
                let time = Time(duration: CMTimeGetSeconds(currentItem.duration), currentTime: CMTimeGetSeconds(currentItem.currentTime()))
                self.delegate?.didTimeProgressChange(time: time)
            }
        }
    }
}
