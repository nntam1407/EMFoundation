//
//  FormAddRowTableCellViewModel.swift
//  ezSafe
//
//  Created by Nguyen Ngoc Tam on 26/06/2021.
//  Copyright © 2021 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import EMFoundation
import Combine
import UIKit

class EMFormAddRowCellViewState {
    @Published public var backgroundColor: UIColor?
    
    @Published public var title: String?

    @Published public var titleLabelFont: UIFont
    @Published public var titleTextColor: UIColor
    @Published public var iconImage: UIImage?

    init(config: EMFormTableAddRowCellConfig) {
        titleLabelFont = config.titleLabelFont
        titleTextColor = config.titleTextColor
        iconImage = config.iconImage
        backgroundColor = config.backgroundColor
    }
}

protocol EMFormAddRowCellViewModelProtocol {
    var viewState: EMFormAddRowCellViewState { get }
}

class EMFormAddRowTableCellViewModel: EMFormAddRowCellViewModelProtocol, EMFormTableCellViewModelProtocol, EMFormTableCellViewModelTaggable {
    public var tag: (any Equatable)?
    public var cellIdentifier: String

    public var viewState: EMFormAddRowCellViewState

    public init(
        cellIdentiifer: String = EMFormTableDefaultCellIdentifier.addRowCell.rawValue,
        config: EMFormTableAddRowCellConfig = .shared
    ) {
        self.cellIdentifier = cellIdentiifer
        viewState = .init(config: config)
    }
}

#endif
