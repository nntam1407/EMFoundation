//
//  DecodeIfPresentNoErrorWrapper.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 14/06/2023.
//

import Foundation

@propertyWrapper public struct DecodeIfPresentNoError<T: Codable & DecodableDefaultSource>: CodableContainer {
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

extension KeyedDecodingContainer {
    public func decode<T>(_ type: DecodeIfPresentNoError<T>.Type, forKey key: Key) throws -> DecodeIfPresentNoError<T> {
        .init(wrappedValue: (try? decodeIfPresent(T.self, forKey: key)) ?? T.defaultValue)
    }

    public func decode<T>(_ type: DecodeIfPresentNoError<T?>.Type, forKey key: Key) throws -> DecodeIfPresentNoError<T?> {
        .init(wrappedValue: (try? decodeIfPresent(T.self, forKey: key)) ?? Optional.defaultValue)
    }
}

extension KeyedDecodingContainer {
    public func decode<T: LosslessStringDecodable>(_ type: DecodeIfPresentNoError<T>.Type, forKey key: Key) throws -> DecodeIfPresentNoError<T> {
        .init(wrappedValue: (try? decodeFromStringIfPresent(T.self, forKey: key)) ?? T.defaultValue)
    }

    public func decode<T: LosslessStringDecodable>(_ type: DecodeIfPresentNoError<T?>.Type, forKey key: Key) throws -> DecodeIfPresentNoError<T?> {
        .init(wrappedValue: (try? decodeFromStringIfPresent(T.self, forKey: key)) ?? Optional.defaultValue)
    }
}


