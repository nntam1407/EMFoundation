//
//  FormTableSectionViewModel.swift
//  ezSafe
//
//  Created by Tam Nguyen on 16/07/2022.
//  Copyright © 2022 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import EMFoundation
import UIKit

public class EMFormTableSectionViewModel: EMFormTableSectionViewModelProtocol, EMFormTableSectionViewModelLayoutProtocol, EMFormTableSectionViewModelUIProtocol {
    public var cellViewModels = Bindable<[EMFormTableCellViewModelProtocol]>([])

    // MARK: FormTableSectionViewModelLayoutProtocol

    // Set UITableView.automaticDimension or .tableViewAutoSizing extension for auto-sizing
    public var headerHeight: CGFloat = 12

    // Set UITableView.automaticDimension or .tableViewAutoSizing extension for auto-sizing
    public var footerHeight: CGFloat = 12

    // MARK: FormTableSectionViewModelUIProtocol

    public var headerViewStyle: EMFormTableSectionHeaderFooterViewStyle = .none

    public var headerCustomViewReusableIdentifier: String?

    public var headerViewModel: Any?

    public var footerViewStyle: EMFormTableSectionHeaderFooterViewStyle = .none

    public var footerCustomViewReusableIdentifier: String?

    public var footerViewModel: Any?

    public init(
        cellViewModels: [EMFormTableCellViewModelProtocol] = []
    ) {
        self.cellViewModels.value = cellViewModels
    }
}

/// Can use this built-in class if style = standard. This can be used for both header and footer view with standard style
public class EMFormTableSectionHeaderFooterStandardViewModel {
    public var title: String = ""

    public init(title: String) {
        self.title = title
    }
}

#endif
