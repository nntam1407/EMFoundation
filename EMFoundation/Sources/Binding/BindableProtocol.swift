//
//  BindableProtocol.swift
//  YoutubeForKids
//
//  Created by Nguyen Ngoc Tam on 31/1/20.
//  Copyright © 2020 Logi. All rights reserved.
//

import Foundation

public protocol BindableProtocol {
    associatedtype ListenerCallback
    associatedtype ValueType

    var value: ValueType { get set }

    func bind(listener: ListenerCallback)

    func bindAndFireEvent(listener: ListenerCallback)

    func fireEvent()

    /// This won't fire event
    /// - Parameter value: new value
    func updateValueSilently(value: ValueType)
}
