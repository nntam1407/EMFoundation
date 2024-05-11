//
//  FormLabelTableViewCellViewModel.swift
//  ezSafe
//
//  Created by Tam Nguyen on 15/02/2022.
//  Copyright © 2022 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import EMFoundation
import Combine
import UIKit

public class EMFormLabelCellViewState {
    @Published public var title: String?
    @Published public var titleTextColor: UIColor
    @Published public var titleAlignment: NSTextAlignment
    @Published public var titleFont: UIFont

    @Published public var secondaryText: String?
    @Published public var secondaryTextColor: UIColor
    @Published public var secondaryTextAlignment: NSTextAlignment
    @Published public var secondaryTextFont: UIFont

    @Published public var backgroundColor: UIColor?

    @Published public var showNextIcon: Bool = false
    @Published public var iconImage: UIImage?
    @Published public var trailingIconImage: UIImage?
    @Published public var selectionStyle: EMFormTableViewCellSelectionStyle

    init(config: EMFormTableLabelCellConfig) {
        titleTextColor = config.titleTextColor
        titleAlignment = config.titleAlignment
        titleFont = config.titleFont
        secondaryTextColor = config.secondaryTextColor
        secondaryTextAlignment = config.secondaryTextAlignment
        secondaryTextFont = config.secondaryTextFont
        selectionStyle = config.selectionStyle
        backgroundColor = config.backgroundColor
    }
}

public protocol EMFormLabelCellViewModelProtocol {
    var viewState: EMFormLabelCellViewState { get }
}

public class EMFormLabelCellViewModel: EMFormTableCellViewModelProtocol, EMFormLabelCellViewModelProtocol, EMFormTableCellViewModelTaggable {
    public var viewState: EMFormLabelCellViewState

    public var cellIdentifier: String
    public var tag: (any Equatable)?
    public var userDidTouchOnCellHandler: ((_ indexPath: IndexPath) -> Void)?

    public init(
        cellIdentiifer: String = EMFormTableDefaultCellIdentifier.labelCell.rawValue,
        config: EMFormTableLabelCellConfig = .shared,
        title: String?
    ) {
        self.cellIdentifier = cellIdentiifer
        
        viewState = EMFormLabelCellViewState(config: config)
        viewState.title = title
    }
}

extension EMFormLabelCellViewModel: EMFormTableCellViewModelTouchableProtocol {
    public func handleUserDidTouchOnCell(atIndexPath indexPath: IndexPath) {
        userDidTouchOnCellHandler?(indexPath)
    }
}

extension EMFormLabelCellViewModel: EMFormTableCellViewModelLayoutProtocol {
    public var isFixedCellHeight: Bool {
        return false
    }

    public var cellHeight: CGFloat? {
        nil
    }
}

#endif
