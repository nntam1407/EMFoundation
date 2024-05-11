//
//  AtomicPropertyWrapper.swift
//  ezSafe
//
//  Created by Tam Nguyen on 11/10/2022.
//  Copyright © 2022 Logi. All rights reserved.
//

import Foundation

@propertyWrapper
public struct EMAtomic<T> {
    private var value: T
    private let lock = NSLock()

    public init(wrappedValue value: T) {
        self.value = value
    }

    public var wrappedValue: T {
        get {
            getValue()
        }
        set {
            setValue(value: newValue)
        }
    }

    private func getValue() -> T {
        lock.lock()
        defer { lock.unlock() }
        return value
    }

    private mutating func setValue(value: T) {
        lock.lock()
        defer { lock.unlock() }
        self.value = value
    }
}
