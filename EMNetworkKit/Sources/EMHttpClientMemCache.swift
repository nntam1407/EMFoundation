//
//  MemCacheManager.swift
//  ChatApp
//
//  Created by Tam Nguyen on 2/3/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import Foundation

#if canImport(AppKit)
import AppKit

public typealias PlatformImage = NSImage
#else
import UIKit

public typealias PlatformImage = UIImage
#endif

class EMHttpClientMemCache: NSObject {
    enum Constants {
        static let defaultCountLimit = 100 // 100 items
        static let defaultTotalCostLimit = 1024 * 1024 * 100 // 10Mb
    }

    // Private mem cache object
    private var memCache: NSCache<AnyObject, PlatformImage> = NSCache()

    var countLimit: Int {
        get {
            memCache.countLimit
        } set {
            memCache.countLimit = newValue
        }
    }

    var totalCostLimit: Int {
        get {
            memCache.totalCostLimit
        } set {
            memCache.totalCostLimit = newValue
        }
    }

    #if canImport(UIKit)
    var clearWhenAppInBackgroundMode: Bool = true {
        didSet {
            NotificationCenter.default.removeObserver(
                self,
                name: UIApplication.didEnterBackgroundNotification,
                object: nil
            )

            if clearWhenAppInBackgroundMode {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(applicationDidEnterBackground(_:)),
                    name: UIApplication.didEnterBackgroundNotification,
                    object: nil
                )
            }
        }
    }
    #endif

    // MARK: Init methods

    override init() {
        super.init()

        // Set default limit and handle events
        memCache.countLimit = Constants.defaultCountLimit
        memCache.totalCostLimit = Constants.defaultTotalCostLimit

        // Default, when app goto backgound we should clear all memcache to reduce memory. Because if in background, app uses too much memory, iOS system can kill app any time
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        // Register notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidReceivedMemoryWarning(_:)),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        #endif
    }

    static let shared: EMHttpClientMemCache = {
        EMHttpClientMemCache()
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Public methods

    func getCacheImage(_ key: String) -> PlatformImage? {
        return memCache.object(forKey: key as AnyObject)
    }

    func cacheImage(_ image: PlatformImage, forKey key: String) {
        let cost = Int(image.size.width * image.size.height * 4) // 4 is 4 byte per pixel
        memCache.setObject(image, forKey: key as AnyObject, cost: cost)
    }

    func removeCacheImage(_ key: String) {
        memCache.removeObject(forKey: key as AnyObject)
    }

    func cleanMemoryCache() {
        memCache.removeAllObjects()
    }

    // MARK: Handle notification events

    @objc func applicationDidReceivedMemoryWarning(_ notif: Notification?) {
        // Clean all memory cache
        cleanMemoryCache()
    }

    @objc func applicationDidEnterBackground(_ notif: Notification?) {
        cleanMemoryCache()
    }
}
