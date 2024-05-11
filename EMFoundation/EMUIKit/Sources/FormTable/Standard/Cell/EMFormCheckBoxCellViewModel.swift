//
//  FormCheckBoxCellViewModel.swift
//  ezSafe
//
//  Created by Tam Nguyen on 14/07/2022.
//  Copyright © 2022 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import EMFoundation
import Combine
import UIKit

public class EMFormCheckBoxCellViewState {
    @Published public var backgroundColor: UIColor?
    
    @Published public var title: String?
    @Published public var subtitle: String?
    @Published public var selected: Bool = false

    @Published public var checkedIconTintColor: UIColor
    @Published public var checkedIconImage: UIImage?

    @Published public var titleFont: UIFont
    @Published public var titleTextColor: UIColor

    @Published public var subtitleFont: UIFont
    @Published public var subtitleTextColor: UIColor

    init(config: EMFormTableCheckBoxCellConfig) {
        checkedIconTintColor = config.checkedIconTintColor
        checkedIconImage = config.checkedIconImage
        titleFont = config.titleFont
        titleTextColor = config.titleTextColor
        backgroundColor = config.backgroundColor
        subtitleFont = config.subtitleFont
        subtitleTextColor = config.subtitleTextColor
    }
}

public protocol EMFormCheckBoxCellViewModelProtocol {
    var viewState: EMFormCheckBoxCellViewState { get }
}

public class EMFormCheckBoxCellViewModel: EMFormTableCellViewModelProtocol, EMFormCheckBoxCellViewModelProtocol, EMFormTableCellViewModelTaggable {
    public var cellIdentifier: String
    public var tag: (any Equatable)?

    public var viewState: EMFormCheckBoxCellViewState

    public var userDidTouchOnCellHandler: ((_ indexPath: IndexPath) -> Void)?

    public init(
        cellIdentiifer: String = EMFormTableDefaultCellIdentifier.checkBoxCell.rawValue,
        config: EMFormTableCheckBoxCellConfig = .shared,
        title: String?
    ) {
        self.cellIdentifier = cellIdentiifer

        viewState = .init(config: config)
        viewState.title = title
    }
}

extension EMFormCheckBoxCellViewModel: EMFormTableCellViewModelTouchableProtocol {
    public func handleUserDidTouchOnCell(atIndexPath indexPath: IndexPath) {
        userDidTouchOnCellHandler?(indexPath)
    }
}

#endif
