//
//  EMMemoryCache.swift
//  MySpace
//
//  Created by Nguyen Ngoc Tam on 25/5/20.
//  Copyright © 2020 Logi. All rights reserved.
//

import Foundation

class EMMemoryCache: EMCacheStorageProtocol {

    private var cache: NSCache<NSString, AnyObject>!

    init() {
        cache = NSCache()
    }

    deinit {
        print("EMMemoryCache deinit")
    }

    // MARK: Implementation

    func saveObject(object: Any, forKey key: String, completion: @escaping () -> Void) {
        cache.setObject(EMMemoryCacheObject(value: object), forKey: key as NSString)
        completion()
    }

    func removeObject(forKey key: String, completion: @escaping () -> Void) {
        cache.removeObject(forKey: key as NSString)
        completion()
    }

    func isKeyExisting(key: String) -> Bool {
        if let _ = cache.object(forKey: key as NSString) {
            return true
        }

        return false
    }

    func getObject<T>(forKey key: String, completion: @escaping (_ object: T?) -> Void) {
        guard let cacheObject = cache.object(forKey: key as NSString) as? EMMemoryCacheObject<Any>, let result = cacheObject.value as? T else {
            completion(nil)
            return
        }

        completion(result)
    }

    // MARK: Mananage memeory

    func applicationDidReceivedMemoryWarningNotification() {
        clearAllCacheData()
    }

    func clearAllCacheData() {
        cache.removeAllObjects()
    }
}
