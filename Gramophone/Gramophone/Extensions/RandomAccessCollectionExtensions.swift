//
//  RandomAccessCollectionExtensions.swift
//  Gramophone
//
//  Created by Firat Yenidunya on 11.09.2021.
//  Copyright © 2021 com.gramophone.firatyenidunya. All rights reserved.
//

import Foundation

extension RandomAccessCollection {
    func element(at index: Index) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        return self[index]
    }
}
