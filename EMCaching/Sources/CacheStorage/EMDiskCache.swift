//
//  EMDiskCache.swift
//  MySpace
//
//  Created by Nguyen Ngoc Tam on 25/5/20.
//  Copyright © 2020 Logi. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

class EMDiskCache: EMCacheStorageProtocol, EMDiskCacheStorageProtocol {

    struct EMDiskCacheConstant {
        static let cacheSubfolder = "/EMDiskCache"
    }

    private var writeFileDispatchQueue: DispatchQueue! // This is serial queue
    private var readFileDispatchQueue: DispatchQueue! // This should be concurent
    var cacheFolderPath: String = ""
    var isPermanent = false

    /// Init method
    /// - Parameter isPermanent:
    /// If this value is false, the cache folder will be created in system cache folder, and the disk's space will be claimed by the system randomly.
    /// If this value is true, the cache folder will be created in user's folder, and the data only be deleted when user delete the app
    init(isPermanent: Bool = false) {
        self.isPermanent = isPermanent
        writeFileDispatchQueue = DispatchQueue(label: "cache.disk.write_file_queue")
        readFileDispatchQueue = DispatchQueue(label: "cache.disk.read_file_queue", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        setupCacheFolder()
    }

    deinit {
        print("EMDiskCache deinit")
    }

    // MARK: Private methods

    private func setupCacheFolder() {
        let searchPath: FileManager.SearchPathDirectory = isPermanent ? .documentDirectory : .cachesDirectory
        guard let applicationCachePath = FileManager.default.urls(for: searchPath, in: .userDomainMask).first?.path else {
            assert(false, "Application cache folder is not found.")
            cacheFolderPath = ""
            return
        }

        cacheFolderPath = (applicationCachePath as NSString).appendingPathComponent(EMDiskCacheConstant.cacheSubfolder)
        print("EMDiskCache folder path: \(String(describing: cacheFolderPath))")

        // Trying to create folder if not existing
        if !FileManager.default.fileExists(atPath: cacheFolderPath) {
            writeFileDispatchQueue.async { [weak self] in
                guard let self = self else {
                    return
                }

                do {
                    try FileManager.default.createDirectory(atPath: self.cacheFolderPath, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    assert(false, "Cannot create cache folder at path: \(String(describing: self.cacheFolderPath)).\nError: \(error.localizedDescription)")
                }
            }
        }
    }

    private func cacheFilePath(forCacheKey cacheKey: String) -> String {
        let fileName = String(format: "%@.tmp", cacheKey)
        let result = (cacheFolderPath as NSString).appendingPathComponent(fileName)

        return result
    }

    private func writeObjectToFile(object: Any, filePath: String) {
        var savingData: Data?

        if let data = object as? Data {
            savingData = data
        } else if let string = object as? String {
            savingData = string.data(using: .utf8)
        }

#if canImport(UIKit)
        if savingData == nil, let image = object as? UIImage {
            savingData = image.jpegData(compressionQuality: 0.5)
        }
#endif

#if canImport(AppKit)
        if savingData == nil, let image = object as? NSImage {
            savingData = image.tiffRepresentation(using: .jpeg, factor: 0.5)
        }
#endif

        if let savingData = savingData {
            writeDataToFile(data: savingData, filePath: filePath)
        } else {
            assert(false, "Unsupported cache object type: \(type(of: object))")
        }
    }

    private func writeDataToFile(data: Data, filePath: String) {
        do {
            let fileURL = URL(fileURLWithPath: filePath)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("EMDiskCache: cannot write data to file path: \(filePath)")
        }
    }

    private func loadObjectFromFile<T>(filePath: String) -> T? {
        guard let data = loadDataFromFile(filePath: filePath) else {
            return nil
        }

        var result: T?

        if T.self == Data.self || T.self == NSData.self {
            result = data as? T
        } else if T.self == String.self || T.self == NSString.self {
            result = String(data: data, encoding: .utf8) as? T
        }

#if canImport(UIKit)
        if result == nil, T.self == UIImage.self {
            result = UIImage(data: data) as? T
        }
#endif

#if canImport(AppKit)
        if result == nil, T.self == NSImage.self {
            result = NSImage(data: data) as? T
        }
#endif

        if result == nil {
            assert(false, "Unsupported cache object type: \(T.self)")
        }

        return result
    }

    private func loadDataFromFile(filePath: String) -> Data? {
        do {
            let fileURL = URL(fileURLWithPath: filePath)
            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            return data
        } catch {
            print("EMDiskCache load Data from file at path: \(filePath)\nError: \(error.localizedDescription)")
        }

        return nil
    }

    // MARK: Implementation

    func saveObject(object: Any, forKey key: String, completion: @escaping () -> Void) {
        writeFileDispatchQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            let filePath = self.cacheFilePath(forCacheKey: key)
            self.writeObjectToFile(object: object, filePath: filePath)

            completion()
        }
    }

    func removeObject(forKey key: String, completion: @escaping () -> Void) {
        writeFileDispatchQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            let filePath = self.cacheFilePath(forCacheKey: key)

            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch {
                print("EMDiskCache remove file at path: \(filePath)\nError: \(error.localizedDescription)")
            }

            completion()
        }
    }

    func isKeyExisting(key: String) -> Bool {
        let filePath = self.cacheFilePath(forCacheKey: key)
        return FileManager.default.fileExists(atPath: filePath)
    }

    func getObject<T>(forKey key: String, completion: @escaping (_ object: T?) -> Void) {
        guard isKeyExisting(key: key) else {
            completion(nil)
            return
        }

        readFileDispatchQueue.async {[weak self] in
            guard let self = self else {
                return
            }

            let filePath = self.cacheFilePath(forCacheKey: key)
            let data: T? = self.loadObjectFromFile(filePath: filePath)

            completion(data)
        }
    }

    // MARK: Mananage memeory

    func applicationDidReceivedMemoryWarningNotification() {
        // Disk cache don't need to handle this
    }

    func clearAllCacheData() {
        // Remove cache folder
        do {
            try FileManager.default.removeItem(atPath: cacheFolderPath)

            // Re-create cache folder
            setupCacheFolder()
        } catch {
            print("EMDiskCache remove all cache daat error: \(error.localizedDescription)")
        }
    }
}
