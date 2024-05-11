//
//  UITableViewExtension.swift
//  Ahacho Business
//
//  Created by Tam Nguyen on 5/16/16.
//  Copyright © 2016 Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import UIKit

public extension UITableView {

    func reloadData(pushAnimated animated: Bool, duration: TimeInterval) {
        if !animated {
            self.layer.removeAnimation(forKey: "UITableViewReloadDataAnimationKey")
            self.reloadData()
        } else {
            let transition = CATransition()
            transition.type = CATransitionType.push
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.fillMode = CAMediaTimingFillMode.forwards
            transition.duration = duration
            transition.subtype = CATransitionSubtype.fromRight
            self.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")

            // Update your data source here
            self.reloadData()
        }
    }

    func reloadData(popAnimated animated: Bool, duration: TimeInterval) {
        if !animated {
            self.layer.removeAnimation(forKey: "UITableViewReloadDataAnimationKey")
            self.reloadData()
        } else {
            let transition = CATransition()
            transition.type = CATransitionType.push
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.fillMode = CAMediaTimingFillMode.forwards
            transition.duration = duration
            transition.subtype = CATransitionSubtype.fromLeft
            self.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")

            // Update your data source here
            self.reloadData()
        }
    }

    func reloadData(dropAnimated animated: Bool, dropSectionHeaders: Bool) {
        if !animated {
            self.reloadData()
            return
        }

        // Start dismiss animated
        let visibleCells = self.visibleCells
        let visibleSectionHeaders = dropSectionHeaders ? self.visbleSectionHeaderViews() : [UIView]()

        if visibleCells.count > 0 {
            UIView.animate(withDuration: 0.15, delay: 0.0, options: UIView.AnimationOptions(), animations: {
                for cell in visibleCells {
                    cell.alpha = 0.0

                    var frame = cell.frame
                    frame.origin.y += 5
                    cell.frame = frame
                }

                for view in visibleSectionHeaders {
                    view.alpha = 0.0

                    var frame = view.frame
                    frame.origin.y += 5
                    view.frame = frame
                }

                }, completion: { (_: Bool) in

                    // Should re-set all cell alpha = 1.0
                    for cell in visibleCells {
                        cell.alpha = 1.0
                    }

                    for view in visibleSectionHeaders {
                        view.alpha = 1.0
                    }

                    // Now start animated for new data
                    self.reloadData()

                    let visibleCells = self.visibleCells
                    let visibleSectionHeaders = dropSectionHeaders ? self.visbleSectionHeaderViews() : [UIView]()

                    if visibleCells.count > 0 {
                        for cell in visibleCells {
                            cell.alpha = 0.0

                            var frame = cell.frame
                            frame.origin.y += 10
                            cell.frame = frame
                        }

                        for view in visibleSectionHeaders {
                            view.alpha = 0.0

                            var frame = view.frame
                            frame.origin.y += 10
                            view.frame = frame
                        }

                        UIView.animate(withDuration: 0.15, delay: 0.0, options: UIView.AnimationOptions(), animations: {
                            for cell in visibleCells {
                                cell.alpha = 1.0

                                var frame = cell.frame
                                frame.origin.y -= 10
                                cell.frame = frame
                            }

                            for view in visibleSectionHeaders {
                                view.alpha = 1.0

                                var frame = view.frame
                                frame.origin.y -= 10
                                view.frame = frame
                            }

                            }, completion: nil)
                    }
            })
        } else {
            // Now start animated
            self.reloadData()

            let visibleCells = self.visibleCells
            let visibleSectionHeaders = dropSectionHeaders ? self.visbleSectionHeaderViews() : [UIView]()

            if visibleCells.count > 0 {
                for cell in visibleCells {
                    cell.alpha = 0.0

                    var frame = cell.frame
                    frame.origin.y += 10
                    cell.frame = frame
                }

                for view in visibleSectionHeaders {
                    view.alpha = 0.0

                    var frame = view.frame
                    frame.origin.y += 10
                    view.frame = frame
                }

                UIView.animate(withDuration: 0.15, delay: 0.0, options: UIView.AnimationOptions(), animations: {
                    for cell in visibleCells {
                        cell.alpha = 1.0

                        var frame = cell.frame
                        frame.origin.y -= 10
                        cell.frame = frame
                    }

                    for view in visibleSectionHeaders {
                        view.alpha = 1.0

                        var frame = view.frame
                        frame.origin.y -= 10
                        view.frame = frame
                    }

                    }, completion: nil)
            }
        }
    }

    // MARK: 
    // MARK: Support methods

    /**
        Get all visible indexes of section header view
     */
    func indexesOfVisibleSectionHeaders() -> [Int] {
        var result = [Int]()

        for index in 0...self.numberOfSections {
            var headerRect: CGRect?
            let sectionHeaderView = self.headerView(forSection: index)

            if sectionHeaderView != nil {
                if self.style == .plain {
                    headerRect = self.rect(forSection: index)
                } else {
                    headerRect = self.rectForHeader(inSection: index)
                }

                let visibleRectOfTableView = CGRect(x: self.contentOffset.x,
                                                    y: self.contentOffset.y,
                                                    width: self.bounds.width,
                                                    height: self.bounds.height)

                if visibleRectOfTableView.intersects(headerRect!) {
                    result.append(index)
                }
            }
        }

        return result
    }

    /**
        Get all visible section header view
    */
    func visbleSectionHeaderViews() -> [UIView] {
        var result = [UIView]()

        let visibleSectionIndex = self.indexesOfVisibleSectionHeaders()

        for index in visibleSectionIndex {
            let sectionHeader = self.headerView(forSection: index)

            if sectionHeader != nil {
                result.append(sectionHeader!)
            }
        }

        return result
    }
}

public extension UITableView {
    func isValidIndexPath(indexPath: IndexPath) -> Bool {
        indexPath.section < numberOfSections && indexPath.row < numberOfRows(inSection: indexPath.section)
    }
}

#endif
