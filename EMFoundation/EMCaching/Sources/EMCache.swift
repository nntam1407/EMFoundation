//
//  EMCachingManager.swift
//  MySpace
//
//  Created by Nguyen Ngoc Tam on 25/5/20.
//  Copyright © 2020 Logi. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class EMCache: EMCacheProtocol {

    private var cacheStorages = [String: EMCacheStorageProtocol]()

    public init(useDefaultMemoryCacheStorge: Bool, useDefaultDiskCacheStorage: Bool) {
        if useDefaultMemoryCacheStorge {
            addCacheStorage(cacheStorage: EMMemoryCache(), cacheStorgeTag: EMCacheStorageTag.memory)
        }

        if useDefaultDiskCacheStorage {
            addCacheStorage(cacheStorage: EMDiskCache(isPermanent: false), cacheStorgeTag: EMCacheStorageTag.temporarilyDisk)

            addCacheStorage(cacheStorage: EMDiskCache(isPermanent: true), cacheStorgeTag: EMCacheStorageTag.permanentDisk)
        }

        // Register all notifications
#if canImport(UIKit)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidReceivedMemoryWarning(notification:)), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
#endif
    }

    deinit {
        print("EMCache deinit")
    }

    // MARK: Manage cache storage

    public func addCacheStorage(cacheStorage: EMCacheStorageProtocol, cacheStorgeTag tag: EMCacheStorageTag) {
        cacheStorages[tag.rawValue] = cacheStorage
    }

    public func cacheStorage(cacheStorgeTag tag: EMCacheStorageTag) -> EMCacheStorageProtocol? {
        guard let cacheStorage = cacheStorages[tag.rawValue] else {
            assert(false, "CacheStorage is not found.")
            return nil
        }

        return cacheStorage
    }

    public func removeCacheStorage(cacheStorgeTag tag: EMCacheStorageTag) {
        cacheStorages[tag.rawValue] = nil
    }

    public func isCacheStorageExisting(cacheStorgeTag tag: EMCacheStorageTag) -> Bool {
        guard cacheStorages[tag.rawValue] != nil else {
            return false
        }

        return true
    }

    // MARK: Data

    public func saveObject(object: Any, forKey key: String, cacheStorgeTag tag: EMCacheStorageTag) {
        let semaphore = DispatchSemaphore(value: 0)

        saveObject(object: object, forKey: key, cacheStorgeTag: tag) {
            semaphore.signal()
        }

        semaphore.wait()
    }

    public func saveObject(object: Any, forKey key: String, cacheStorgeTag tag: EMCacheStorageTag, completion: @escaping () -> Void) {
        guard let cacheStorage = cacheStorage(cacheStorgeTag: tag) else {
            completion()
            return
        }

        cacheStorage.saveObject(object: object, forKey: key) {
            completion()
        }
    }

    public func removeObject(forKey key: String, cacheStorgeTag tag: EMCacheStorageTag) {
        let semaphore = DispatchSemaphore(value: 0)

        removeObject(forKey: key, cacheStorgeTag: tag) {
            semaphore.signal()
        }

        semaphore.wait()
    }

    public func removeObject(forKey key: String, cacheStorgeTag tag: EMCacheStorageTag, completion: @escaping () -> Void) {
        guard let cacheStorage = cacheStorage(cacheStorgeTag: tag) else {
            completion()
            return
        }

        cacheStorage.removeObject(forKey: key) {
            completion()
        }
    }

    public func isKeyExisting(key: String, cacheStorgeTag tag: EMCacheStorageTag) -> Bool {
        guard let cacheStorage = cacheStorage(cacheStorgeTag: tag) else {
            return false
        }

        return cacheStorage.isKeyExisting(key: key)
    }

    public func getObject<T>(forKey key: String, cacheStorgeTag tag: EMCacheStorageTag) -> T? {
        let semaphore = DispatchSemaphore(value: 0)
        var result: T?

        getObject(forKey: key, cacheStorgeTag: tag) { (object: T?) in
            result = object
            semaphore.signal()
        }

        semaphore.wait()
        return result
    }

    public func getObject<T>(forKey key: String, cacheStorgeTag tag: EMCacheStorageTag, completion: @escaping (T?) -> Void) {
        guard let cacheStorage = cacheStorage(cacheStorgeTag: tag) else {
            completion(nil)
            return
        }

        cacheStorage.getObject(forKey: key) { (object) in
            completion(object)
        }
    }

    // MARK: Clear caching data

    public func clearCache(cacheStorgeTag tag: EMCacheStorageTag) {
        guard let cacheStorage = cacheStorage(cacheStorgeTag: tag) else {
            return
        }

        cacheStorage.clearAllCacheData()
    }

    public func clearAllCaches() {
        for (_, cacheStorage) in cacheStorages {
            cacheStorage.clearAllCacheData()
        }
    }
}

extension EMCache {
    @objc private func applicationDidReceivedMemoryWarning(notification: Notification) {
        for (_, cacheStorage) in cacheStorages {
            cacheStorage.applicationDidReceivedMemoryWarningNotification()
        }
    }
}
