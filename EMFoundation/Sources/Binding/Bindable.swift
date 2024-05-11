//
//  Bindable.swift
//  YoutubeForKids
//
//  Created by Nguyen Ngoc Tam on 21/1/20.
//  Copyright © 2020 Logi. All rights reserved.
//

import Foundation

public class Bindable<T>: NSObject, BindableProtocol {
    public typealias ListenerCallback = (T) -> Void
    public typealias ValueType = T

    private var listener: ListenerCallback?

    private var privateValue: ValueType
    public var value: ValueType {
        get {
            return privateValue
        }
        set {
            privateValue = newValue
            fireEvent()
        }
    }

    public init(_ value: ValueType) {
        privateValue = value
    }

    public func bind(listener: @escaping ListenerCallback) {
        self.listener = listener
    }

    public func bindAndFireEvent(listener: @escaping ListenerCallback) {
        bind(listener: listener)
        listener(value)
    }

    public func fireEvent() {
        listener?(self.value)
    }

    public func updateValueSilently(value: T) {
        privateValue = value
    }
}
