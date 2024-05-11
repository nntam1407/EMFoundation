//
//  NSDictionaryExtension.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 11/22/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import Foundation

public extension NSDictionary {

    // Convert to Json string
    func toJsonString() -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions()) else {
            return nil
        }

        return NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String?
    }

    func stringValueForKey(_ key: String) -> String? {
        let rawValue = self[key]

        return (rawValue as? String)
    }

    /**
     * Return not null String value
     * If value = nil, return ""
     */
    func stringValueNotNull(_ key: String) -> String {
        return (value(forKey: key) as? String) ?? ""
    }

    func numberValueNotNull(_ key: String) -> NSNumber {
        (self[key] as? NSNumber) ?? NSNumber(value: 0)
    }

    func numberValueForKey(_ key: String, defaultValue: NSNumber? = nil) -> NSNumber? {
        let rawValue = self[key]
        let numberValue = rawValue as? NSNumber

        if numberValue == nil {
            return defaultValue
        }

        return numberValue
    }

    func intValueForKeyOptional(_ key: String) -> Int? {
        if let rawValue = self[key] as? NSNumber {
            return rawValue.intValue
        }

        return nil
    }

    /// Method get intValue from dictionary
    ///
    /// - Parameter key: Key of value in dictionary
    /// - Returns: 0 if does not contain int value with this key
    func intValueForKey(_ key: String) -> Int {
        if let rawValue = self[key] as? NSNumber {
            return rawValue.intValue
        }

        if let rawValue = self[key] as? String {
            return Int(rawValue) ?? 0
        }

        return 0
    }

    func intValueForKey(_ key: String, defaultValue: Int) -> Int {
        if let rawValue = self[key] as? NSNumber {
            return rawValue.intValue
        }

        if let rawValue = self[key] as? String {
            return Int(rawValue) ?? defaultValue
        }

        return defaultValue
    }

    func int64ValueForKey(_ key: String) -> Int64 {
        if let rawValue = self[key] as? NSNumber {
            return rawValue.int64Value
        }

        if let rawValue = self[key] as? String {
            return Int64(rawValue) ?? 0
        }

        return 0
    }

    func uintValueForKey(_ key: String) -> UInt {
        if let rawValue = self[key] as? NSNumber {
            return rawValue.uintValue
        }

        if let rawValue = self[key] as? String {
            return UInt(rawValue) ?? 0
        }

        return 0
    }

    func doubleValue(_ key: String) -> Double {
        if let rawValue = self[key] as? NSNumber {
            return rawValue.doubleValue
        }

        if let rawValue = self[key] as? String {
            return Double(rawValue) ?? 0.0
        }

        return 0.0
    }

    func doubleValue(_ key: String, defaultValue: Double) -> Double {
        if let rawValue = self[key] as? NSNumber {
            return rawValue.doubleValue
        }

        if let rawValue = self[key] as? String {
            return Double(rawValue) ?? defaultValue
        }

        return defaultValue
    }

    func boolValue(_ key: String) -> Bool {
        if let rawValue = self[key] as? NSNumber {
            return rawValue.boolValue
        }

        if let rawValue = self[key] as? String {
            return Bool(rawValue) ?? false
        }

        return false
    }

    func boolValue(_ key: String, _ defaultValue: Bool) -> Bool {
        if let rawValue = self[key] as? NSNumber {
            return rawValue.boolValue
        }

        if let rawValue = self[key] as? String {
            return Bool(rawValue) ?? false
        }

        return defaultValue
    }

    func dateValue(_ key: String) -> Date? {
        let rawValue = self[key]

        if let date = rawValue as? Date {
            return date
        } else if let rawValueString = rawValue as? String {
            return Date.dateFromDotNetTimeString(rawValueString)
        }

        return nil
    }

    func dateValueNotNull(_ key: String) -> Date {
        return dateValue(key) ?? Date()
    }

    func dateValueNotNull(_ key: String, format: String) -> Date {
        guard let rawValue = self[key] else { return Date() }

        if let date = rawValue as? Date {
            return date
        } else if let rawValueString = rawValue as? String {
            let dateFomatter = DateFormatter()
            dateFomatter.dateFormat = format
            let date = dateFomatter.date(from: rawValueString)

            return date ?? Date()
        }

        return Date()
    }

    func dateValueWithEpochTime(_ key: String) -> Date? {
        let numberValue = self.numberValueForKey(key, defaultValue: nil)

        if numberValue == nil {
            return nil
        } else {
            return Date(timeIntervalSince1970: numberValue!.doubleValue / 1000.0)
        }
    }

    func dictionaryForKey(_ key: String) -> NSDictionary? {
        let rawValue = self[key]

        return (rawValue as? NSDictionary)
    }

    func arrayForKey(_ key: String) -> NSArray? {
        let rawValue = self[key]

        return (rawValue as? NSArray)
    }
}

public extension Dictionary {
    func toJsonString() -> String? {
        (self as NSDictionary).toJsonString()
    }
    
    func toJsonData() -> Data? {
        (self as NSDictionary).toJsonString()?.data(using: String.Encoding.utf8)
    }
}

public extension Dictionary where Self == [String: String] {
    func queryString() -> String {
        var components = URLComponents()
        components.queryItems = map {
            URLQueryItem(name: $0, value: $1)
        }
        return components.url?.absoluteString ?? ""
    }
}

// MARK: Subscript with keyPath

public extension Dictionary {
    subscript<T>(keyPath keyPath: String) -> T? {
        self[keyPath: keyPath] as? T
    }

    subscript(keyPath keyPath: String) -> Any? {
        get {
            guard let keyPath = Dictionary.keyPathKeys(forKeyPath: keyPath)
            else { return nil }
            return getValue(forKeyPath: keyPath)
        }
        set {
            guard let keyPath = Dictionary.keyPathKeys(forKeyPath: keyPath),
                  let newValue = newValue else { return }
            self.setValue(newValue, forKeyPath: keyPath)
        }
    }

    static private func keyPathKeys(forKeyPath: String) -> [Key]? {
        let keys = forKeyPath.components(separatedBy: ".").compactMap({ $0 as? Key })
        return keys.isEmpty ? nil : keys
    }

    // recursively (attempt to) access queried subdictionaries
    // (keyPath will never be empty here; the explicit unwrapping is safe)
    private func getValue(forKeyPath keyPath: [Key]) -> Any? {
        guard let firstKey = keyPath.first, let value = self[firstKey] else { return nil }
        return keyPath.count == 1 ? value : (value as? [Key: Any])
            .flatMap { $0.getValue(forKeyPath: Array(keyPath.dropFirst())) }
    }

    // recursively (attempt to) access the queried subdictionaries to
    // finally replace the "inner value", given that the key path is valid
    private mutating func setValue(_ value: Any, forKeyPath keyPath: [Key]) {
        guard let firstKey = keyPath.first else { return }
        if keyPath.count == 1 {
            self[firstKey] = value as? Value
        } else {
            if self[firstKey] == nil {
                self[firstKey] = ([Key: Value]() as? Value)
            }
            if var subDict = self[firstKey] as? [Key: Value] {
                subDict.setValue(value, forKeyPath: Array(keyPath.dropFirst()))
                self[firstKey] = subDict as? Value
            }
        }
    }
}

public extension Dictionary where Value: Equatable {
    func key(forValue value: Value) -> Key? {
        first(where: { $1 == value })?.key
    }
}

public extension Dictionary where Self == [String: Any] {
    func findAllValueRecursively<T>(byKey key: String) -> [T] {
        var result = [T]()

        self.forEach { (subKey, subValue) in
            if subKey == key, let value = subValue as? T {
                result.append(value)
            } else if let subDict = subValue as? [String: Any] {
                // Find recursively
                let subResults: [T] = subDict.findAllValueRecursively(byKey: key)
                result.append(contentsOf: subResults)
            } else if let subDicts = subValue as? [[String: Any]] {
                subDicts.forEach {
                    result.append(contentsOf: $0.findAllValueRecursively(byKey: key))
                }
            }
        }

        return result
    }
}
