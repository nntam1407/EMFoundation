//
//  DispatchQueue+Extension.swift
//  EMFoundation
//
//  Created by Tam Nguyen on 21/3/24.
//

import Foundation

public extension DispatchQueue {
    class func asyncOnMain(execute: @escaping () -> Void) {
        if Thread.current.isMainThread {
            execute()
            return
        }

        main.async {
            execute()
        }
    }
}
