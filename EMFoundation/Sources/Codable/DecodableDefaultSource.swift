//
//  DecodableDefaultSource.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 14/06/2023.
//

import Foundation

public protocol DecodableDefaultSource {
    static var defaultValue: Self { get }
}

extension String: DecodableDefaultSource {
    public static var defaultValue: String { "" }
}

extension Int: DecodableDefaultSource {
    public static var defaultValue: Int { 0 }
}

extension Float: DecodableDefaultSource {
    public static var defaultValue: Float { 0 }
}

extension Double: DecodableDefaultSource {
    public static var defaultValue: Double { 0 }
}

extension Decimal: DecodableDefaultSource {
    public static var defaultValue: Decimal { .zero }
}

extension Bool: DecodableDefaultSource {
    public static var defaultValue: Bool { false }
}

extension Optional: DecodableDefaultSource {
    public static var defaultValue: Optional<Wrapped> { nil }
}

extension Array: DecodableDefaultSource {
    public static var defaultValue: Array<Element> { [] }
}

extension Dictionary: DecodableDefaultSource {
    public static var defaultValue: Dictionary<Key, Value> { [:] }
}
