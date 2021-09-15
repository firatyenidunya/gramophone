//
//  GramophoneState.swift
//  Gramophone
//
//  Created by Firat Yenidunya on 11.09.2021.
//  Copyright © 2021 com.gramophone.firatyenidunya. All rights reserved.
//

import Foundation

public enum GramophoneState: Int, CustomStringConvertible {
    case playing
    case paused
    case loading
    case failed
    case unknown

    public var description: String {
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
