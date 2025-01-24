//
//  EMAtomicArray.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 6/3/24.
//

import Foundation

open class EMThreadSafeArray<Element>: @unchecked Sendable {

    private var array: [Element]
    private let locker = NSRecursiveLock()

    public init(array: [Element] = [Element]()) {
        self.array = array
    }

    public var startIndex: Array<Element>.Index {
        locker.lock()
        defer { locker.unlock() }

        return array.startIndex
    }

    public var endIndex: Array<Element>.Index {
        locker.lock()
        defer { locker.unlock() }

        return array.endIndex
    }

    public subscript(position: Int) -> Element {
        get {
            locker.lock()
            defer { locker.unlock() }

            return array[position]
        } set {
            locker.lock()
            defer { locker.unlock() }

            array[position] = newValue
        }
    }

    public func index(after i: Int) -> Int {
        locker.lock()
        defer { locker.unlock() }

        return array.index(after: i)
    }
}

public extension EMThreadSafeArray {
    func append(_ newElement: Element) {
        locker.lock()
        defer { locker.unlock() }

        array.append(newElement)
    }

    func append<S>(contentsOf newElements: S) where Element == S.Element, S : Sequence {
        locker.lock()
        defer { locker.unlock() }

        array.append(contentsOf: newElements)
    }

    var first: Element? {
        locker.lock()
        defer { locker.unlock() }

        return array.first
    }

    var last: Element? {
        locker.lock()
        defer { locker.unlock() }

        return array.last
    }

    func removeAll(keepingCapacity keepCapacity: Bool = false) {
        locker.lock()
        defer { locker.unlock() }

        array.removeAll(keepingCapacity: keepCapacity)
    }

    @discardableResult
    func removeFirst() -> Element? {
        locker.lock()
        defer { locker.unlock() }

        return array.removeFirst()
    }

    @discardableResult
    func removeLast() -> Element? {
        locker.lock()
        defer { locker.unlock() }

        return array.removeLast()
    }

    @discardableResult
    func remove(at index: Int) -> Element? {
        locker.lock()
        defer { locker.unlock() }

        guard index >= 0, index < array.count else {
            return nil
        }

        return array.remove(at: index)
    }

    func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        locker.lock()
        defer { locker.unlock() }

        return try array.first(where: predicate)
    }
}
