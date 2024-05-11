//
//  RangeExtension.swift
//  AskApp
//
//  Created by Tam Nguyen on 7/25/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//

import Foundation

public extension Range {

    /**
        Return random value in range
    */
    var randomInt: Int {
        guard let lowerBound = lowerBound as? Int,
              let upperBound = upperBound as? Int
        else { return 0 }

        let offset = abs(lowerBound)
        let mini = UInt32(lowerBound + offset)
        let maxi = UInt32(upperBound + offset)

        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}
