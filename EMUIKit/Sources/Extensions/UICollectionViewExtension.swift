//
//  UICollectionExtension.swift
//  MySpace
//
//  Created by Nguyen Ngoc Tam on 7/5/20.
//  Copyright © 2020 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import UIKit

public extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        guard let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect) else {
            return []
        }

        let result = allLayoutAttributes.map {
            $0.indexPath
        }

        return result
    }
}

public extension UICollectionView {
    func isValidIndexPath(indexPath: IndexPath) -> Bool {
        indexPath.section < numberOfSections && indexPath.row < numberOfItems(inSection: indexPath.section)
    }
}

#endif
