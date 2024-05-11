//
//  FormTableViewProtocols.swift
//  ezSafe
//
//  Created by Tam Nguyen on 15/02/2022.
//  Copyright © 2022 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import EMFoundation
import UIKit

public enum EMFormTableDefaultCellIdentifier: String {
    case textFieldCell = "form_table_text_field_cell"
    case textViewCell = "form_table_text_view_cell"
    case addRowCell = "form_table_add_row_cell"
    case switchCell = "form_table_switch_cell"
    case labelCell = "form_table_label_cell"
    case checkBoxCell = "form_table_check_box_cell"
}

public enum EMFormTableViewCellSelectionStyle {
    case none
    case blue
    case gray
}

public extension CGFloat {
    static let tableViewAutoSizing = UITableView.automaticDimension
}

// MARK: For table viewModel

public protocol EMFormTableViewModelProtocol {
    associatedtype SectionViewModelType: EMFormTableSectionViewModelProtocol

    var sectionViewModels: Bindable<[SectionViewModelType]> { get }
}

public extension EMFormTableViewModelProtocol {
    func sectionViewModel(section: Int) -> EMFormTableSectionViewModelProtocol? {
        sectionViewModels.value.object(atIndex: section)
    }

    func cellViewModel(section: Int, row: Int) -> EMFormTableCellViewModelProtocol? {
        sectionViewModels.value.object(atIndex: section)?.cellViewModels.value.object(atIndex: row)
    }

    func totalSections() -> Int {
        sectionViewModels.value.count
    }

    func totalCells(section: Int) -> Int {
        sectionViewModels.value.object(atIndex: section)?.cellViewModels.value.count ?? 0
    }
}

// MARK: For table section viewModel

public protocol EMFormTableSectionViewModelProtocol {
    var cellViewModels: Bindable<[EMFormTableCellViewModelProtocol]> { get }
}

public protocol EMFormTableSectionViewModelLayoutProtocol {
    /// Set UITableView.autoDemension for auto-sizing footer view
    var headerHeight: CGFloat { get }

    /// Set UITableView.autoDemension for auto-sizing footer view
    var footerHeight: CGFloat { get }
}

public enum EMFormTableSectionHeaderFooterViewStyle {
    case none // meaning no header/footer view
    case standard
    case custom
}

public protocol EMFormTableSectionViewModelUIProtocol {
    // MARK: For header

    var headerViewStyle: EMFormTableSectionHeaderFooterViewStyle { get }

    // Must set if headerViewStyle == custom
    var headerCustomViewReusableIdentifier: String? { get }

    // Custom header view should conform to protocol FormTableSectionHeaderFooterViewBindableProtocol when using FormTableViewPresenter
    // Use standard FormTableSectionHeaderFooterStandardViewModel class if you don't want to create your own custom header view
    var headerViewModel: Any? { get }

    // MARK: For footer

    var footerViewStyle: EMFormTableSectionHeaderFooterViewStyle { get }

    // Must set if footerViewStyle == custom
    var footerCustomViewReusableIdentifier: String? { get }

    // Custom footer view should conform to protocol FormTableSectionHeaderFooterViewBindableProtocol when using FormTableViewPresenter
    // Use standard FormTableSectionHeaderFooterStandardViewModel class if you don't want to create your own custom footer view
    var footerViewModel: Any? { get }
}

/// Conform this protocol to be able use auto-bind viewModel when using FormTableViewPresenter class
public protocol EMFormTableSectionHeaderFooterViewBindableProtocol {
    func bindViewModel(viewModel: Any)
}

// MARK: For cell

/// All cells of the TableForm should implement this protocol in other to use class FormTableViewPresenter. The cell's viewModel instance will be passed into cell class automatically
public protocol EMFormTableCellBindableProtocol {
    func unbindViewModel()

    func bindViewModel(viewModel: Any)
}

// MARK: For cell viewModel

/// All viewModel of the cells of the TableForm should implement this protocol in order to use class FormTableViewPresenter
public protocol EMFormTableCellViewModelProtocol {
    var cellIdentifier: String { get }
}

public protocol EMFormTableCellViewModelTaggable {
    /// Useful to detect which cell is this. This can be anything. You can cast this tag to your type (maybe enum) then check
    var tag: (any Equatable)? { get set }
}

/// Implement this on ViewModel of a cell if you want to handle didSelectCellAtIndexPath event by the cell inself instead. The instance of FormTableViewPresenter won't receive that event
public protocol EMFormTableCellViewModelTouchableProtocol {
    func handleUserDidTouchOnCell(atIndexPath indexPath: IndexPath)
}

public protocol EMFormTableCellViewModelLayoutProtocol {
    var isFixedCellHeight: Bool { get }

    /// This will be ignored if isFixedCellHeight == false
    var cellHeight: CGFloat? { get }
}

#endif
