//
//  SequenceExtension.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 9/5/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

extension Sequence {
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
