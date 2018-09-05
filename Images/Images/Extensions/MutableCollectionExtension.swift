//
//  MutableCollectionExtension.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 9/5/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

extension MutableCollection {
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}
