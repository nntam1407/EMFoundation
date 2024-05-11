//
//  MapperProtocol.swift
//  YoutubeForKids
//
//  Created by Nguyen Ngoc Tam on 31/1/20.
//  Copyright © 2020 Logi. All rights reserved.
//

import Foundation

public protocol MapperTypeProtocol {
    associatedtype InputType
    associatedtype OutputType
}

public protocol MapperInputToOutputProtocol: MapperTypeProtocol {
    func toOutput(input: InputType) -> OutputType

    func toOutputs(inputs: [InputType]) -> [OutputType]
}

public protocol MapperOutputToInputProtocol: MapperTypeProtocol {
    func toInput(output: OutputType) -> InputType

    func toInputs(outputs: [OutputType]) -> [InputType]
}

// MARK: Default implementation for protocol

public extension MapperInputToOutputProtocol {
    func toOutputs(inputs: [InputType]) -> [OutputType] {
        let result = inputs.map { (input) -> OutputType in
            return toOutput(input: input)
        }

        return result
    }
}

public extension MapperOutputToInputProtocol {
    func toInputs(outputs: [OutputType]) -> [InputType] {
        let result = outputs.map { (output) -> InputType in
            return toInput(output: output)
        }

        return result
    }
}
