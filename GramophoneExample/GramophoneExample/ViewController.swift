//
//  ViewController.swift
//  GramophoneExample
//
//  Created by Firat Yenidunya on 17.06.2020.
//  Copyright © 2020 com.gramophone.firatyenidunya. All rights reserved.
//

import UIKit
import Gramophone

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

        gramophone.add(gramophoneItems: [GramophoneItem(url: Bundle.main.url(forResource: "BeatIt", withExtension: ".mp3")!,
                                                        title: "beatit",
                                                        duration: 350,
                                                        album: "First Album",
                                                        artist: "First Artist",
                                                        artwork: nil),
                                         GramophoneItem(url: URL(string: "https://s3.amazonaws.com/kargopolov/kukushka.mp3")!,
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

    func didTimeProgressChange(_ gramaphone: Gramophone, time: Time) {
        print(time.currentTime)
        print(time.duration)
    }
}
