//
//  EMCacheProtocol.swift
//  MySpace
//
//  Created by Nguyen Ngoc Tam on 25/5/20.
//  Copyright © 2020 Logi. All rights reserved.
//

import Foundation

public enum EMCacheStorageTag: String {
    case memory = "memory"
    case temporarilyDisk = "temporarily.disk" // The OS will decide when to flush the cache
    case permanentDisk = "permanent.disk" // The cache will be flushed only when user delete the app
}

public protocol EMCacheProtocol {

    // MARK: Manage cache storage

    func addCacheStorage(cacheStorage: EMCacheStorageProtocol, cacheStorgeTag tag: EMCacheStorageTag)

    func cacheStorage(cacheStorgeTag tag: EMCacheStorageTag) -> EMCacheStorageProtocol?

    func removeCacheStorage(cacheStorgeTag tag: EMCacheStorageTag)

    func isCacheStorageExisting(cacheStorgeTag tag: EMCacheStorageTag) -> Bool

    // MARK: For object type

    func saveObject(object: Any, forKey key: String, cacheStorgeTag tag: EMCacheStorageTag)

    func saveObject(object: Any, forKey key: String, cacheStorgeTag tag: EMCacheStorageTag, completion: @escaping () -> Void)

    func removeObject(forKey key: String, cacheStorgeTag tag: EMCacheStorageTag)

    func removeObject(forKey key: String, cacheStorgeTag tag: EMCacheStorageTag, completion: @escaping () -> Void)

    func isKeyExisting(key: String, cacheStorgeTag tag: EMCacheStorageTag) -> Bool

    func getObject<T>(forKey key: String, cacheStorgeTag tag: EMCacheStorageTag) -> T?

    func getObject<T>(forKey key: String, cacheStorgeTag tag: EMCacheStorageTag, completion: @escaping (_ object: T?) -> Void)

    // MARK: Clear caching data

    func clearCache(cacheStorgeTag tag: EMCacheStorageTag)

    func clearAllCaches()
}
