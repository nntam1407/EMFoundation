//
//  FileUtils.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 1/28/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import Foundation

#if canImport(MobileCoreServices)
import MobileCoreServices
#endif

public class EMFileUtils: NSObject {
    public class func mimeTypeForExtension(_ fileExtension: String) -> String {
        let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
        let str = UTTypeCopyPreferredTagWithClass(UTI!.takeUnretainedValue(), kUTTagClassMIMEType)

        if str == nil {
            return "application/octet-stream"
        } else {
            return str!.takeUnretainedValue() as String
        }
    }

    // Get application document directory
    public class func applicationDocumentDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    public class func applicationCachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    public class func isFileExist(_ filePath: String) -> Bool {
        FileManager.default.fileExists(atPath: filePath)
    }

    @discardableResult
    public class func createFolderAtPath(_ path: String) -> Bool {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: path) {
            var error: NSError?

            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch let error1 as NSError {
                error = error1
            }

            if error != nil {
                DLog("Cannot create folder at path: \(path)\nError: \(error!.localizedDescription)")
                return false
            }
        }

        return true
    }

    public class func fileSize(_ filePath: String) -> UInt {
        let fileManager = FileManager.default

        if EMFileUtils.isFileExist(filePath) {
            let fileAttrs: [FileAttributeKey: Any]?
            do {
                fileAttrs = try fileManager.attributesOfItem(atPath: filePath)
            } catch _ {
                fileAttrs = nil
            }

            if fileAttrs != nil {
                let fileSize = fileAttrs![FileAttributeKey.size] as? UInt
                return fileSize ?? 0
            }
        }

        return 0
    }

    @discardableResult
    public class func copyFile(_ srcPath: String, destPath: String) -> Bool {
        let fileManager = FileManager.default
        var error: NSError?

        do {
            try fileManager.copyItem(atPath: srcPath, toPath: destPath)
        } catch let error1 as NSError {
            error = error1
        }

        if error != nil {
            DLog("Cannot copy file.\nError: \(error!.localizedDescription)")
            return false
        }

        return true
    }

    @discardableResult
    public class func moveFile(_ srcPath: String, destPath: String) -> Bool {
        // First copy file
        if EMFileUtils.copyFile(srcPath, destPath: destPath) {
            // Delete src file
            let fileManager = FileManager.default
            var error: NSError?

            do {
                try fileManager.removeItem(atPath: srcPath)
            } catch let error1 as NSError {
                error = error1
            }

            if error != nil {
                DLog("Move file. Cannot delete src file.\nError: \(error!.localizedDescription)")
            }
        } else {
            return false
        }

        return true
    }

    @discardableResult
    public class func deleteFile(_ filePath: String) -> Bool {
        guard FileManager.default.fileExists(atPath: filePath) else {
            return true
        }

        var error: NSError?

        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch let error1 as NSError {
            error = error1
        }

        if error != nil {
            DLog("Cannot delete file.\nError: \(error!.localizedDescription)")
            return false
        }

        return true
    }

    public class func createCustomShareURL(forFileURL fileURL: URL, customFileName fileName: String) -> URL {
        let fileManager = FileManager.default
        let tempDirectoryURL = fileManager.temporaryDirectory
        let linkURL = tempDirectoryURL.appendingPathComponent(fileName)

        do {
            if fileManager.fileExists(atPath: linkURL.path) {
                try fileManager.removeItem(at: linkURL)
            }
            try fileManager.linkItem(at: fileURL, to: linkURL)
            return linkURL
        } catch let error as NSError {
            DLog("Cannot create custom share URL for file: \(error)")
            return fileURL
        }
    }
}

// MARK: System storage
public extension EMFileUtils {
    class func systemTotalDiskSpaceInBytes() throws -> UInt64  {
        let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
        let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.uint64Value
        return space ?? 0
    }

    class func systemFreeDiskSpaceInBytes() throws -> UInt64 {
        let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
        let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.uint64Value
        return freeSpace ?? 0
    }
}

// MARK: For calculate size
public extension EMFileUtils {
    class func calculateFileSize(atPath path: String) throws -> UInt64 {
        var isDir: Bool? = nil
        return try calculateFileSize(atPath: path, isDirectory: &isDir)
    }

    class func calculateFileSize(atPath path: String, isDirectory: inout Bool?) throws -> UInt64 {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDir) else { return 0 }
        isDirectory = isDir.boolValue

        if isDir.boolValue {
            var totalSize: UInt64 = 0
            let fileURL = URL(fileURLWithPath: path)
            let subFileURLs = try FileManager.default.contentsOfDirectory(
                at: fileURL,
                includingPropertiesForKeys: []
            )

            for subFileURL in subFileURLs {
                // Recursively calculate size of file or its sub folders/files
                let subFileSize = try? calculateFileSize(atPath: subFileURL.path)
                totalSize += subFileSize ?? 0
            }

            return totalSize
        } else {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            let fileSize = (attributes[FileAttributeKey.size] as? NSNumber)?.uint64Value
            return fileSize ?? 0
        }
    }
}
