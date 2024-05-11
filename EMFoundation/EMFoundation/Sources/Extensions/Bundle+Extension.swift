//
//  BundleExtension.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 12/11/2023.
//

import Foundation

extension Bundle {
    private static let bundleCache = NSCache<NSNumber, Bundle>()

    class var current: Bundle {
        let caller = Thread.callStackReturnAddresses[1]

        if let bundle = bundleCache.object(forKey: caller) {
            return bundle
        }

        var info = Dl_info(dli_fname: "", dli_fbase: nil, dli_sname: "", dli_saddr: nil)
        dladdr(caller.pointerValue, &info)
        let imagePath = String(cString: info.dli_fname)

        for bundle in Bundle.allBundles + Bundle.allFrameworks {
            if let execPath = bundle.executableURL?.resolvingSymlinksInPath().path,
               imagePath == execPath {
                bundleCache.setObject(bundle, forKey: caller)
                return bundle
            }
        }
        fatalError("Bundle not found for caller \"\(String(cString: info.dli_sname))\"")
    }
}
