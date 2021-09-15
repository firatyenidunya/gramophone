//
//  GramophoneDelegate.swift
//  Gramophone
//
//  Created by Firat Yenidunya on 16.09.2021.
//  Copyright © 2021 com.gramophone.firatyenidunya. All rights reserved.
//

import Foundation

public protocol GramophoneDelegate: AnyObject {
    func didStateChange(_ gramophone: Gramophone, to state: GramophoneState)
    func didItemPlay(_ gramophone: Gramophone, at index: Int)
    func didTimeProgressChange(_ gramaphone: Gramophone, time: Time)
}

// Default implementation of GramophoneDelegate functions.
extension GramophoneDelegate {
    func didStateChange(_ gramophone: Gramophone, to state: GramophoneState) { }
    func didItemPlay(_ gramophone: Gramophone, at index: Int) { }
    func didTimeProgressChange(_ gramaphone: Gramophone, time: Time) { }
}
