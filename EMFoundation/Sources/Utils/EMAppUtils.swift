//
//  AppUtils.swift
//  YoutubeForKids
//
//  Created by Nguyen Ngoc Tam on 21/1/20.
//  Copyright © 2020 Logi. All rights reserved.
//

import Foundation

public class EMAppUtils {
    class func appBundleName() -> String? {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
    }
}
