//
//  FormTextContentTableCellViewModel.swift
//  ezSafe
//
//  Created by Nguyen Ngoc Tam on 08/05/2021.
//  Copyright © 2021 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import EMFoundation
import Combine
import UIKit

class EMFormTextViewCellViewState {
    @Published public var backgroundColor: UIColor?

    @Published public var title: String?
    @Published public var content: String?
    @Published public var contentInputPlaceholder: String?

    @Published public var isEditable: Bool = true

    @Published public var doneButtonTitle: String
    @Published public var titleFont: UIFont
    @Published public var titleTextColor: UIColor
    @Published public var textFont: UIFont
    @Published public var textColor: UIColor

    public var becomeFirstResponder = PassthroughSubject<Void, Never>()

    init(
        config: EMFormTableTextViewCellConfig,
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

protocol EMFormTextViewCellViewModelProtocol {
    var viewState: EMFormTextViewCellViewState { get }
}

class EMFormTextViewCellViewModel: EMFormTextViewCellViewModelProtocol, EMFormTableCellViewModelProtocol, EMFormTableCellViewModelTaggable {
    var cellIdentifier: String
    var tag: (any Equatable)?

    var viewState: EMFormTextViewCellViewState

    init(
        cellIdentiifer: String = EMFormTableDefaultCellIdentifier.textViewCell.rawValue,
        config: EMFormTableTextViewCellConfig = .shared,
        localization: EMFormTableLocalizationConfig = .shared
    ) {
        self.cellIdentifier = cellIdentiifer
        viewState = .init(config: config, localization: localization)
    }
}

extension EMFormTextViewCellViewModel: EMFormTableCellViewModelLayoutProtocol {
    var isFixedCellHeight: Bool {
        false
    }

    var cellHeight: CGFloat? {
        0.0
    }
}

#endif
