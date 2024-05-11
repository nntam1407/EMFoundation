//
//  FormTableViewPresenter.swift
//  ezSafe
//
//  Created by Tam Nguyen on 15/04/2022.
//  Copyright © 2022 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import UIKit

public protocol EMFormTableViewPresenterProtocol {
    associatedtype FormTableViewModelType: EMFormTableViewModelProtocol

    var tableView: UITableView? { get }
    var tableViewModel: FormTableViewModelType { get }

    var allowsPullToRefresh: Bool { get set }
    var allowsLoadMore: Bool { get set }

    func reloadTableView()

    func endPullToRefresh()
    func endLoadMore()
}

public protocol EMFormTableViewPresenterDelegate: AnyObject {
    func formTableViewPresenterNeedsReloadData<T>(presenter: EMFormTableViewPresenter<T>)
    func formTableViewPresenterNeedsLoadMoreData<T>(presenter: EMFormTableViewPresenter<T>)

    func formTableViewPresenterDidReloadTableView<T>(presenter: EMFormTableViewPresenter<T>)

    func formTableViewPresenter<T>(presenter: EMFormTableViewPresenter<T>, didSelectCell cell: UITableViewCell, atIndexPath indexPath: IndexPath)
}

public extension EMFormTableViewPresenterDelegate {
    func formTableViewPresenterNeedsReloadData<T>(presenter: EMFormTableViewPresenter<T>) {}
    func formTableViewPresenterNeedsLoadMoreData<T>(presenter: EMFormTableViewPresenter<T>) {}
    func formTableViewPresenterDidReloadTableView<T>(presenter: EMFormTableViewPresenter<T>) {}

    func formTableViewPresenter<T>(presenter: EMFormTableViewPresenter<T>, didSelectCell cell: UITableViewCell, atIndexPath indexPath: IndexPath) {}
}

private enum EMFormTableViewPresenterConstants {
    static let estimateRowHeight: CGFloat = 50.0
    static let estimateSectionHeaderHeight: CGFloat = 12
    static let estimateSectionFooterHeight: CGFloat = 12
}

public class EMFormTableViewPresenter <FormTableViewModelType>:
    NSObject,
    EMFormTableViewPresenterProtocol,
    UITableViewDelegate,
    UITableViewDataSource,
    EMFormTextViewTableViewCellDelegate where FormTableViewModelType: EMFormTableViewModelProtocol {

    weak var delegate: EMFormTableViewPresenterDelegate?

    public weak var tableView: UITableView?
    public var tableViewModel: FormTableViewModelType

    public var allowsPullToRefresh: Bool = false {
        didSet {
            if allowsPullToRefresh {
                tableView?.refreshControl = refreshControl
            } else {
                tableView?.refreshControl = nil
            }
        }
    }

    public var allowsLoadMore: Bool = false {
        didSet {
            if allowsLoadMore {
                loadMoreControl.removeFromSuperview()
                tableView?.addSubview(loadMoreControl)
            } else {
                loadMoreControl.removeFromSuperview()
            }
        }
    }

    private lazy var refreshControl: EMMaterialRefreshControl = {
        let control = EMMaterialRefreshControl()
        control.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
        return control
    }()

    private lazy var loadMoreControl: EMMaterialInfiniteScrollingControl = {
        let control = EMMaterialInfiniteScrollingControl()
        control.addTarget(self, action: #selector(loadMoreControlValueChanged), for: .valueChanged)
        return control
    }()

    var configuration: EMFormTableConfiguration = .shared

    public init(
        tableView: UITableView,
        tableViewModel: FormTableViewModelType
    ) {
        self.tableView = tableView
        self.tableViewModel = tableViewModel

        super.init()

        tableView.delegate = self
        tableView.dataSource = self

        bindTableViewModel()
    }

    private func bindTableViewModel() {
        tableViewModel.sectionViewModels.bind { [weak self] _ in
            self?.reloadTableView()
        }
    }

    public func reloadTableView() {
        tableView?.reloadData()

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.formTableViewPresenterDidReloadTableView(presenter: self)
        }
    }

    public func endPullToRefresh() {
        refreshControl.endRefreshing()
    }

    public func endLoadMore() {
        loadMoreControl.endLoading()
    }

    // MARK: Events

    @objc private func refreshControlValueChanged() {
        delegate?.formTableViewPresenterNeedsReloadData(presenter: self)
    }

    @objc private func loadMoreControlValueChanged() {
        delegate?.formTableViewPresenterNeedsLoadMoreData(presenter: self)
    }

    // MARK: UITableViewDelegate, UITableViewDataSource
    // MARK: For section

    public func numberOfSections(in tableView: UITableView) -> Int {
        tableViewModel.totalSections()
    }

    // MARK: For section header

    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        EMFormTableViewPresenterConstants.estimateSectionHeaderHeight
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let layout = tableViewModel.sectionViewModel(section: section) as? EMFormTableSectionViewModelLayoutProtocol
        else {
            return .tableViewAutoSizing
        }

        return layout.headerHeight
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let uiViewModel = tableViewModel.sectionViewModel(section: section) as? EMFormTableSectionViewModelUIProtocol else {
            return nil
        }

        guard uiViewModel.headerViewStyle == .standard,
              let standardHeaderViewModel = uiViewModel.headerViewModel as? EMFormTableSectionHeaderFooterStandardViewModel else {
            return nil
        }

        return standardHeaderViewModel.title
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let uiViewModel = tableViewModel.sectionViewModel(section: section) as? EMFormTableSectionViewModelUIProtocol else {
            return UIView()
        }

        guard uiViewModel.headerViewStyle == .custom else {
            if uiViewModel.headerViewStyle == .standard {
                return nil
            }

            return UIView()
        }

        guard let identifier = uiViewModel.headerCustomViewReusableIdentifier,
              let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) else {
            assert(false, "Invalid header view identifier")
            return UIView()
        }

        if let bindableView = headerView as? EMFormTableSectionHeaderFooterViewBindableProtocol,
           let headerViewModel = uiViewModel.headerViewModel {
            bindableView.bindViewModel(viewModel: headerViewModel)
        }

        return headerView
    }

    // MARK: For section footer

    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        EMFormTableViewPresenterConstants.estimateSectionFooterHeight
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let layout = tableViewModel.sectionViewModel(section: section) as? EMFormTableSectionViewModelLayoutProtocol
        else {
            return .tableViewAutoSizing
        }

        return layout.footerHeight
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let uiViewModel = tableViewModel.sectionViewModel(section: section) as? EMFormTableSectionViewModelUIProtocol else {
            return nil
        }

        guard uiViewModel.footerViewStyle == .standard,
              let standardFooterViewModel = uiViewModel.footerViewModel as? EMFormTableSectionHeaderFooterStandardViewModel else {
            return nil
        }

        return standardFooterViewModel.title
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let uiViewModel = tableViewModel.sectionViewModel(section: section) as? EMFormTableSectionViewModelUIProtocol else {
            return UIView()
        }

        guard uiViewModel.footerViewStyle == .custom else {
            if uiViewModel.footerViewStyle == .standard {
                return nil
            }

            return UIView()
        }

        guard let identifier = uiViewModel.footerCustomViewReusableIdentifier,
              let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) else {
            assert(false, "Invalid footer view identifier")
            return UIView()
        }

        if let bindableView = footerView as? EMFormTableSectionHeaderFooterViewBindableProtocol,
           let footerViewModel = uiViewModel.footerViewModel {
            bindableView.bindViewModel(viewModel: footerViewModel)
        }

        return footerView
    }

    // MARK: For cells

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewModel.totalCells(section: section)
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        EMFormTableViewPresenterConstants.estimateRowHeight
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellViewModelLayout = tableViewModel.cellViewModel(section: indexPath.section, row: indexPath.row) as? EMFormTableCellViewModelLayoutProtocol else {
            return .tableViewAutoSizing
        }

        if cellViewModelLayout.isFixedCellHeight {
            assert(cellViewModelLayout.cellHeight != nil, "EMFormTableViewPresenter: Must provide a valid cell's height")
            return cellViewModelLayout.cellHeight ?? EMFormTableViewPresenterConstants.estimateRowHeight
        }

        return .tableViewAutoSizing
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellViewModel = tableViewModel.cellViewModel(section: indexPath.section, row: indexPath.row) else {
            assert(false, "Invalid indexPath or cellViewModel type")
            return UITableViewCell()
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.cellIdentifier) else {
            assert(false, "Can't dequeue reusable cell")
            return UITableViewCell()
        }

        // Bind view model for cell
        if let formCell = cell as? EMFormTableCellBindableProtocol {
            formCell.bindViewModel(viewModel: cellViewModel)
        }

        // Handle cell's delegates
        if let textViewCell = cell as? EMFormTextViewTableViewCell {
            textViewCell.delegate = self
        }

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath),
              let cellViewModel = tableViewModel.cellViewModel(section: indexPath.section, row: indexPath.row) else {
            assert(false, "Invalid cell indexPath")
            return
        }

        if let touchableViewModel = cellViewModel as? EMFormTableCellViewModelTouchableProtocol {
            touchableViewModel.handleUserDidTouchOnCell(atIndexPath: indexPath)
        } else {
            delegate?.formTableViewPresenter(presenter: self, didSelectCell: cell, atIndexPath: indexPath)
        }
    }

    // MARK: FormTextViewTableViewCellDelegate

    public func formTextViewTableViewCellNeedRefreshLayout(cell: EMFormTextViewTableViewCell) {
        tableView?.beginUpdates()
        tableView?.endUpdates()
    }
}

public extension EMFormTableViewPresenter {
    func register(_ cellClass: AnyClass?, forTableCellReuseIdentifier identifier: String) {
        tableView?.register(cellClass, forCellReuseIdentifier: identifier)
    }

    func register(_ aClass: AnyClass?, forTableHeaderFooterViewReuseIdentifier identifier: String) {
        tableView?.register(aClass, forHeaderFooterViewReuseIdentifier: identifier)
    }
}

#endif
