//
//  EMCacheStorageProtocol.swift
//  MySpace
//
//  Created by Nguyen Ngoc Tam on 25/5/20.
//  Copyright © 2020 Logi. All rights reserved.
//

import Foundation

public protocol EMCacheStorageProtocol {
    func saveObject(object: Any, forKey key: String, completion: @escaping () -> Void)

    func removeObject(forKey key: String, completion: @escaping () -> Void)

    func isKeyExisting(key: String) -> Bool

    func getObject<T>(forKey key: String, completion: @escaping (_ object: T?) -> Void)

    // MARK: Mananage memeory

    func applicationDidReceivedMemoryWarningNotification()

    func clearAllCacheData()
}

/// Disk cache should conform to this protocol
public protocol EMDiskCacheStorageProtocol {
    var cacheFolderPath: String { get }
}
