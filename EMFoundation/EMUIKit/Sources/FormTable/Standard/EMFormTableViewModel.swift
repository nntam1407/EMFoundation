//
//  FormTableViewModel.swift
//  ezSafe
//
//  Created by Tam Nguyen on 16/07/2022.
//  Copyright © 2022 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import EMFoundation

public class EMFormTableViewModel: EMFormTableViewModelProtocol {
    public typealias SectionViewModelType = EMFormTableSectionViewModel

    public var sectionViewModels = Bindable<[EMFormTableSectionViewModel]>([])

    public init() {}
}

public extension EMFormTableViewModel {
    func findCellViewModel<T, Tag: Equatable>(cellTag: Tag) -> T? {
        for section in sectionViewModels.value {
            for row in section.cellViewModels.value {
                guard let taggableRow = row as? EMFormTableCellViewModelTaggable else {
                    continue
                }

                guard let tag = taggableRow.tag as? Tag, tag == cellTag else {
                    continue
                }

                return row as? T
            }
        }

        return nil
    }

    func findCellViewModelIndexPath<Tag: Equatable>(cellTag: Tag) -> IndexPath? {
        for (sectionIndex, section) in sectionViewModels.value.enumerated() {
            for (rowIndex, row) in section.cellViewModels.value.enumerated() {
                guard let taggableRow = row as? EMFormTableCellViewModelTaggable else {
                    continue
                }

                guard let tag = taggableRow.tag as? Tag, tag == cellTag else {
                    continue
                }

                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }

        return nil
    }
}

#endif
