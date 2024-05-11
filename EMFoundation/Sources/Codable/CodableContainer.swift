//
//  EMCodableContainer.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 14/06/2023.
//

import Foundation

public protocol CodableContainer: Codable {
    associatedtype Value: Codable
    var wrappedValue: Value { get }
}

extension CodableContainer {
    public init(from decoder: Decoder) throws {
        fatalError("Shouldn't call this directly!")
    }

    public func encode(to encoder: Encoder) throws {
        fatalError("Shouldn't call this directly")
    }
}

extension KeyedEncodingContainer {
    public mutating func encode<T: CodableContainer>(_ value: T, forKey key: KeyedEncodingContainer<K>.Key) throws {
        try encode(value.wrappedValue, forKey: key)
    }
}
