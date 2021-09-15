//
//  GramophoneItem.swift
//  Gramophone
//
//  Created by Firat Yenidunya on 11.09.2021.
//  Copyright © 2021 com.gramophone.firatyenidunya. All rights reserved.
//

import UIKit

public struct GramophoneItem {
    public var url: URL
    public var title: String?
    public var duration: Double?
    public var album: String?
    public var artist: String?
    public var artwork: UIImage?

    public init(url: URL,
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
