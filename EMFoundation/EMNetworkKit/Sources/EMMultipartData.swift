//
//  MultipartData.swift
//  AskApp
//
//  Created by Tam Nguyen on 7/16/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//

import Foundation

public enum EMMultipartDataType {
    case jsonData
    case file
}

public class EMMultipartData {
    var data: Data
    var partName: String
    var fileName: String?
    var dataType: EMMultipartDataType

    public init (data: Data, partName: String, fileName: String?, dataType: EMMultipartDataType) {
        self.data = data
        self.partName = partName
        self.dataType = dataType
        self.fileName = fileName
    }

    public init (value: Any, partName: String) {
        self.data = "\(value)".data(using: String.Encoding.utf8)!
        self.partName = partName
        self.dataType = .jsonData
    }

    public init (dictionary value: NSDictionary, partName: String) {
        self.data = value.toJsonString()!.data(using: String.Encoding.utf8)!
        self.partName = partName
        self.dataType = .jsonData
    }

    public init (array value: [Any], partName: String) {
        let objcArray = NSMutableArray(array: value)

        let jsonData: Data?

        do {
            jsonData = try JSONSerialization.data(withJSONObject: objcArray, options: JSONSerialization.WritingOptions())
        } catch _ {
            jsonData = nil
        }

        if jsonData == nil {
            self.data = "[]".data(using: String.Encoding.utf8)!
        } else {
            self.data = jsonData!
        }

        self.partName = partName
        self.dataType = .jsonData
    }

    // MARK: Public methods

    public func toMultipartData(_ boundary: String) -> Data {
        let data = NSMutableData()

        data.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8, allowLossyConversion: true)!)

        if self.dataType == .jsonData {
            data.append(("Content-Disposition: form-data; name=\"\(self.partName)\"\r\n").data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        } else {
            if self.fileName == nil {
                self.fileName = ""
            }

            data.append(("Content-Disposition: form-data; name=\"\(self.partName)\"; filename=\"\(self.fileName!)\"\r\n").data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        }

        // Set content type
        data.append(("Content-Type: \(self.httpContentType())\r\n\r\n").data(using: String.Encoding.utf8, allowLossyConversion: true)!)

        // Append data
        data.append(self.data)

        data.append(("\r\n").data(using: String.Encoding.utf8, allowLossyConversion: true)!)

        return data as Data
    }

    public func httpContentType() -> String {
        return self.dataType == .jsonData ? "application/json" : "application/octet-stream"
    }
}
