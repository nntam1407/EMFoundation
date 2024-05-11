//
//  StringDecodable.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 14/06/2023.
//

import Foundation

public protocol StringDecodable {
    init?(decodedString string: String)
}

extension Bool: StringDecodable {
    public init?(decodedString string: String) {
        switch string.lowercased() {
        case "0", "false":
            self = false
        case "1", "true":
            self = true
        default:
            return nil
        }
    }
}

extension Int: StringDecodable {
    public init?(decodedString string: String) {
        self.init(string)
    }
}

extension Float: StringDecodable {
    public init?(decodedString string: String) {
        self.init(string)
    }
}

extension Double: StringDecodable {
    public init?(decodedString string: String) {
        self.init(string)
    }
}

extension Decimal: StringDecodable {
    public init?(decodedString string: String) {
        self.init(string: string)
    }
}

extension Decimal: LosslessStringConvertible {
    public init?(_ description: String) {
        self.init(string: description)
    }
}

public typealias LosslessStringDecodable = Decodable & StringDecodable & LosslessStringConvertible

extension KeyedDecodingContainer {
    public func decodeFromString<T>(_ type: T.Type, forKey key: KeyedDecodingContainer.Key) throws -> T where T: LosslessStringDecodable {
        if let decoded = try? decode(type, forKey: key) {
            return decoded
        }

        let string = try decode(String.self, forKey: key)
        guard let decoded = T(decodedString: string) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: description(type, string))
        }

        return decoded
    }

    public func decodeFromStringIfPresent<T>(_ type: T.Type, forKey key: KeyedDecodingContainer.Key) throws -> T? where T: LosslessStringDecodable {
        guard let string = try? decodeIfPresent(String.self, forKey: key) else {
            return try decodeIfPresent(type, forKey: key)
        }

        guard let decoded = T(decodedString: string) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: description(type, string))
        }

        return decoded
    }
}

extension UnkeyedDecodingContainer {
    public mutating func decodeFromStringFirst<T>(_ type: T.Type) throws -> T where T: LosslessStringDecodable {
        guard let string = try? decode(String.self) else {
            return try decode(type)
        }

        guard let decoded = T(decodedString: string) else {
            throw DecodingError.dataCorruptedError(in: self, debugDescription: description(type, string))
        }

        return decoded
    }
}

private func description<T>(_ type: T.Type, _ string: String) -> String {
    "Expected to decode \(T.self) from a string (\"\(string)\") but the string is not valid!"
}
