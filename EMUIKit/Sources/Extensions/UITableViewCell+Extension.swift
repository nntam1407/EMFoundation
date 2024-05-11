//
//  UITableViewCell+Extension.swift
//  ezSafe
//
//  Created by Tam Nguyen on 19/07/2022.
//  Copyright © 2022 Logi. All rights reserved.
//

#if canImport(UIKit)

import Foundation
import UIKit

public extension UITableViewCell {
    var tableView: UITableView? {
        var view = superview
        while view != nil, !(view is UITableView) {
            view = view?.superview
        }

        return view as? UITableView
    }

    var indexPath: IndexPath? {
        tableView?.indexPath(for: self)
    }
}

#endif
