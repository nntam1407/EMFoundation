//
//  DispatchUtils.swift
//  YoutubeForKids
//
//  Created by Nguyen Ngoc Tam on 21/1/20.
//  Copyright © 2020 Logi. All rights reserved.
//

import Foundation

public class EMDispatchUtils {
    public class func dispatchAfterDelay(_ delay: TimeInterval, queue: DispatchQueue, block: @escaping () -> Void) {
        let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        queue.asyncAfter(deadline: time, execute: block)
    }

    public class func dispatchOnMainThreadIfNeeded(block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
