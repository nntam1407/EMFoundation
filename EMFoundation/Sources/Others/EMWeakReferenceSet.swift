//
//  WeakArray.swift
//  MySpace
//
//  Created by Nguyen Ngoc Tam on 28/5/20.
//  Copyright © 2020 Logi. All rights reserved.
//

import Foundation

public struct EMWeakReferenceSet {
    private var container = NSHashTable<AnyObject>.weakObjects()

    public init() {}

    public func add(_ object: AnyObject) {
        container.add(object)
    }

    public func remove(_ object: AnyObject) {
        container.remove(object)
    }

    public func contains(_ object: AnyObject) -> Bool {
        return container.contains(object)
    }

    public func enumerate(handler: (_ object: AnyObject) -> Void) {
        let allDelegates = container.allObjects

        for object in allDelegates {
            handler(object)
        }
    }

    /// Enumerate to all valid items. This function is using generic "T" to help you cast item to the type you want to use in handler closure
    /// - Parameter handler: handler method for this item
    public func enumerate<T>(handler: (_ object: T) -> Void) {
        enumerate { (object) in
            guard let object = object as? T else {
                return
            }

            handler(object)
        }
    }
}
