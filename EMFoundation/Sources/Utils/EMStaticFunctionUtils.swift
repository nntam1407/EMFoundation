//
//  StaticFunctionUtils.swift
//  ezSafe
//
//  Created by Tam Nguyen on 02/10/2022.
//  Copyright © 2022 Logi. All rights reserved.
//

import Foundation

// MARK: Method without class Utils

public func DLog(_ format: String, _ args: CVarArg...) {
    #if DEBUG
        let logMessage = String(format: format, arguments: args)
        print(logMessage)
    #endif

    // Do nothing if this is not debug mode
}
