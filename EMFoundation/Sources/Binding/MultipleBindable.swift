//
//  MultipleBindable.swift
//  YoutubeForKids
//
//  Created by Nguyen Ngoc Tam on 21/1/20.
//  Copyright © 2020 Logi. All rights reserved.
//

import Foundation

// This class support multiple listeners

public class MultipleBindable<T>: BindableProtocol {
    public typealias ListenerCallback = (T) -> Void
    public typealias ValueType = T

    private var listeners = [ListenerCallback]()

    private var privateValue: ValueType
    public var value: ValueType {
        get {
            privateValue
        }
        set {
            privateValue = newValue
            fireEvent()
        }
    }

    public init(_ value: ValueType) {
        self.privateValue = value
    }

    public func bind(listener: @escaping ListenerCallback) {
        listeners.append(listener)
    }

    public func bindAndFireEvent(listener: @escaping ListenerCallback) {
        bind(listener: listener)
        listener(value)
    }

    public func removeAllBindingListeners() {
        listeners.removeAll()
    }

    public func numberOfListeners() -> Int {
        return listeners.count
    }

    public func fireEvent() {
        for listener in listeners {
            listener(self.value)
        }
    }

    public func updateValueSilently(value: T) {
        self.privateValue = value
    }
}
