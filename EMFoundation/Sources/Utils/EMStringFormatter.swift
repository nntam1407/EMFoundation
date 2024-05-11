//
//  EMStringFormatter.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 23/09/2023.
//

import Foundation

public class EMStringFormatter {
    public class func displayedFileSize(sizeInBytes size: UInt, includeSpacing spacing: Bool = true) -> String {
        if size == 0 { return spacing ? "0 B" : "0B" }

        let sizeDisplayUnits = ["B", "KB", "MB", "GB", "TB"]
        let digitGroups = Int(log10(Double(size)) / log10(1024.0));

        return String(
            format: "%.02f%@%@",
            Float(size) / powf(1024.0, Float(digitGroups)),
            spacing ? " " : "",
            sizeDisplayUnits[digitGroups]
        )
    }
}
