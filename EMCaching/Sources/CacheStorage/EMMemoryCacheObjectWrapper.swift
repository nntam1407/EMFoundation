//
//  EMMemoryCacheObjectWrapper.swift
//  MySpace
//
//  Created by Nguyen Ngoc Tam on 25/5/20.
//  Copyright © 2020 Logi. All rights reserved.
//

import Foundation

class EMMemoryCacheObjec<T> {
    let value: T

    init(value: T) {
        self.value = value
    }
}
