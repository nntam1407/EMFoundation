//
//  FormSwitchTableViewCellViewModel.swift
//  ezSafe
//
//  Created by Tam Nguyen on 14/02/2022.
//  Copyright © 2022 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import EMFoundation
import Combine
import UIKit

public class EMFormSwitchCellViewState {
    @Published public var backgroundColor: UIColor?

    @Published public var title: String?
    @Published public var value: Bool = false

    @Published public var titleFont: UIFont
    @Published public var titleTextColor: UIColor

    init(config: EMFormTableSwitchCellConfig) {
        titleFont = config.titleFont
        titleTextColor = config.titleTextColor
        backgroundColor = config.backgroundColor
    }
}

public protocol EMFormSwitchCellViewModelProtocol {
    var viewState: EMFormSwitchCellViewState { get }
}

public class EMFormSwitchCellViewModel: EMFormSwitchCellViewModelProtocol, EMFormTableCellViewModelProtocol, EMFormTableCellViewModelTaggable {
    public var cellIdentifier: String
    public var tag: (any Equatable)?

    public var viewState: EMFormSwitchCellViewState

    public var valueChangedHandler: ((Bool) -> Void)?

    private var bindingSubscriptions = Set<AnyCancellable>()

    public init(
        cellIdentiifer: String = EMFormTableDefaultCellIdentifier.switchCell.rawValue,
        config: EMFormTableSwitchCellConfig = .shared,
        title: String?,
        value: Bool = false
    ) {
        self.cellIdentifier = cellIdentiifer
        
        viewState = .init(config: config)
        viewState.title = title
        viewState.value = value

        registerObservers()
    }

    private func registerObservers() {
        viewState.$value.sink { [weak self] value in
            guard let self else { return }
            self.valueChangedHandler?(value)
        }.store(in: &bindingSubscriptions)
    }
}

#endif
