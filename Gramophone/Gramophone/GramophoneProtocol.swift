//
//  GramophoneProtocol.swift
//  Gramophone
//
//  Created by Firat Yenidunya on 16.09.2021.
//  Copyright © 2021 com.gramophone.firatyenidunya. All rights reserved.
//

import Foundation

public protocol GramophoneProtocol {
    var delegate: GramophoneDelegate? { get set }
    var index: Int { get }
    var gramophoneItems: [GramophoneItem] { get }
    var state: GramophoneState { get }

    /// Plays item at current index.
    func play()

    /// Plays item at given index.
    /// If index is out of range, returns false and does nothing.
    /// Otherwise plays audio at given index and returns true.
    @discardableResult
    func play(at index: Int) -> Bool

    /// Plays next audio.
    func playNext()

    /// Plays previous audio.
    func playPreviously()

    /// Pauses audio.
    func pause()

    /// Adds given gramophone items to end of the current list.
    func add(gramophoneItems: [GramophoneItem])

    /// Adds item to end of the list.
    func add(gramophoneItem: GramophoneItem)

    /// Adds item to given index.
    func add(gramophoneItem: GramophoneItem, to index: Int)

    /// Removes item from given index.
    /// If remove operation fails, returns false otherwise returns true.
    /// If removed item is playing at the time, automatically plays next audio.
    /// - Complexity: O(n)
    @discardableResult
    func removeItem(at index: Int) -> Bool

    /// Removes all items.
    /// Pauses player if it is playing.
    /// - Complexity: O(1)
    func removeAll()
}
