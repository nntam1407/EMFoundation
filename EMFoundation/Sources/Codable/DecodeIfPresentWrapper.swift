//
//  DecodeIfPresentWrapper.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 14/06/2023.
//

import Foundation

@propertyWrapper public struct DecodeIfPresent<T: Codable & DecodableDefaultSource>: CodableContainer {
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

extension DecodeIfPresent: Equatable where T: Equatable {}

extension KeyedDecodingContainer {
    public func decode<T>(_ type: DecodeIfPresent<T>.Type, forKey key: Key) throws -> DecodeIfPresent<T> {
        .init(wrappedValue: (try? decodeIfPresent(T.self, forKey: key)) ?? T.defaultValue)
    }

    public func decode<T>(_ type: DecodeIfPresent<T?>.Type, forKey key: Key) throws -> DecodeIfPresent<T?> {
        .init(wrappedValue: (try? decodeIfPresent(T.self, forKey: key)) ?? Optional.defaultValue)
    }
}

extension KeyedDecodingContainer {
    public func decode<T: LosslessStringDecodable>(_ type: DecodeIfPresent<T>.Type, forKey key: Key) throws -> DecodeIfPresent<T> {
        .init(wrappedValue: (try? decodeFromStringIfPresent(T.self, forKey: key)) ?? T.defaultValue)
    }

    public func decode<T: LosslessStringDecodable>(_ type: DecodeIfPresent<T?>.Type, forKey key: Key) throws -> DecodeIfPresent<T?> {
        .init(wrappedValue: (try? decodeFromStringIfPresent(T.self, forKey: key)) ?? Optional.defaultValue)
    }
}
