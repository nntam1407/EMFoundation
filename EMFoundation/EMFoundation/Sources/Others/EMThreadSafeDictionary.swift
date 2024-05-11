//
//  ThreadSafeDictionary.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 19/2/24.
//

import Foundation

open class EMThreadSafeDictionary<V: Hashable, T>: Collection {

    private var dictionary: [V: T]
    private let locker = NSRecursiveLock()

    public var keys: Dictionary<V, T>.Keys {
        locker.lock()
        defer { locker.unlock() }

        return dictionary.keys
    }

    public var values: Dictionary<V, T>.Values {
        locker.lock()
        defer { locker.unlock() }

        return dictionary.values
    }

    public var startIndex: Dictionary<V, T>.Index {
        locker.lock()
        defer { locker.unlock() }
            
        return dictionary.startIndex
    }

    public var endIndex: Dictionary<V, T>.Index {
        locker.lock()
        defer { locker.unlock() }

        return dictionary.endIndex
    }

    public init(dict: [V: T] = [V:T]()) {
        dictionary = dict
    }

    // this is because it is an apple protocol method
    // swiftlint:disable identifier_name
    public func index(after i: Dictionary<V, T>.Index) -> Dictionary<V, T>.Index {
        locker.lock()
        defer { locker.unlock() }

        return dictionary.index(after: i)
    }
    // swiftlint:enable identifier_name

    public subscript(key: V) -> T? {
        get {
            locker.lock()
            defer { locker.unlock() }

            return dictionary[key]
        } set {
            locker.lock()
            defer { locker.unlock() }

            dictionary[key] = newValue
        }
    }

    // has implicity get
    public subscript(index: Dictionary<V, T>.Index) -> Dictionary<V, T>.Element {
        locker.lock()
        defer { locker.unlock() }

        return dictionary[index]
    }

    @discardableResult
    public func removeValue(forKey key: V) -> T? {
        locker.lock()
        defer { locker.unlock() }

        return dictionary.removeValue(forKey: key)
    }

    public func removeAll() {
        locker.lock()
        defer { locker.unlock() }

        dictionary.removeAll()
    }
}
