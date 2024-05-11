//
//  FormTextFieldTableCellViewModel.swift
//  ezSafe
//
//  Created by Nguyen Ngoc Tam on 26/06/2021.
//  Copyright © 2021 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import UIKit
import EMFoundation
import Combine

public class EMFormTextFieldCellViewState {
    @Published public var backgroundColor: UIColor?

    @Published public var title: String?

    @Published public var content: String?  {
        didSet {
            contentDidChange.send(content)
        }
    }

    @Published public var contentInputPlaceholder: String?

    @Published public var isEditable: Bool = true
    @Published public var keyboardType: UIKeyboardType = .default
    @Published public var autocapitalizationType: UITextAutocapitalizationType = .sentences
    @Published public var isSecureTextEntry: Bool = false

    @Published public var doneButtonTitle: String
    @Published public var titleFont: UIFont
    @Published public var titleTextColor: UIColor
    @Published public var textFont: UIFont
    @Published public var textColor: UIColor

    public var becomeFirstResponder = PassthroughSubject<Void, Never>()

    public var contentDidChange = PassthroughSubject<String?, Never>()

    init(
        config: EMFormTableTextFieldCellConfig,
        localization: EMFormTableLocalizationConfig
    ) {
        doneButtonTitle = localization.doneLocalized
        titleFont = config.titleFont
        titleTextColor = config.titleTextColor
        textFont = config.textFont
        textColor = config.textColor
        backgroundColor = config.backgroundColor
    }
}

public protocol EMFormTextFieldCellViewModelProtocol: AnyObject {
    var viewState: EMFormTextFieldCellViewState { get }
}

public class EMFormTextFieldCellViewModel: EMFormTextFieldCellViewModelProtocol, EMFormTableCellViewModelProtocol, EMFormTableCellViewModelTaggable {
    public var cellIdentifier: String
    public var tag: (any Equatable)?

    public var viewState: EMFormTextFieldCellViewState

    public init(
        cellIdentiifer: String = EMFormTableDefaultCellIdentifier.textFieldCell.rawValue,
        config: EMFormTableTextFieldCellConfig = .shared,
        localization: EMFormTableLocalizationConfig = .shared
    ) {
        self.cellIdentifier = cellIdentiifer
        viewState = .init(config: config, localization: localization)
    }
}

extension EMFormTextFieldCellViewModel: EMFormTableCellViewModelLayoutProtocol {
    public var isFixedCellHeight: Bool {
        true
    }

    public var cellHeight: CGFloat? {
        60.0
    }
}

#endif
