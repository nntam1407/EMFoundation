//
//  NSObjectExtension.swift
//  ChatApp
//
//  Created by Tam Nguyen Ngoc on 2/28/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import Foundation

public extension NSObject {
    func memoryAddressString() -> String {
        return "\(unsafeBitCast(self, to: Int.self))"
    }

    func className() -> String {
        String(describing: type(of: self))
    }

    class func className() -> String {
        String(describing: self)
    }
}
