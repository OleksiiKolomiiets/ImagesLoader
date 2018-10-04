//
//  CircleArea.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 10/2/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

struct CircleArea {
    let centr   : CGPoint
    let radius  : CGFloat
}

extension CircleArea {
    init(with rect: CGRect) {
        let radius = rect.size.height * 0.9 / 2
        self.init(centr: rect.centr, radius: radius)
    }
}
