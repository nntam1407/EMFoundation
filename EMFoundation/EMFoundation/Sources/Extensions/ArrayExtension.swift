//
//  ArrayExtension.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 12/1/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import Foundation

public extension Array {

    func object(atIndex index: Int) -> Element? {
        guard index >= 0 && index < count else {
            return nil
        }

        return self[index]
    }

    mutating func safeRemove(at index: Int) {
        guard index >= 0, index < count else { return }
        remove(at: index)
    }

    /**
     * Methods remove object in this array
     */
    mutating func removeObject<U: Equatable>(_ object: U) {
        var index: Int?
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }

        if (index) != nil {
            self.remove(at: index!)
        }
    }

    mutating func removeObjects<U: Equatable>(_ objects: [U]) {
        for (_, objectToRemove) in objects.enumerated() {
            self.removeObject(objectToRemove)
        }
    }

    func combineStrings(sepatateString: String) -> String? {
        var result: String?

        if let strings = self as? [String] {
            if strings.count == 0 {
                result = ""
            } else {
                for subString in strings {
                    if result == nil {
                        result = subString
                    } else {
                        result! += String(format: "%@%@", sepatateString, subString)
                    }
                }
            }
        }

        return result
    }

    func filterAndSafelyCast<T>(elementType: T.Type) -> [T] {
        return (filter({ $0 is T }) as? [T]) ?? []
    }
}
