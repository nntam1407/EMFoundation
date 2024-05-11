//
//  UIUtils.swift
//  YoutubeForKids
//
//  Created by Nguyen Ngoc Tam on 21/1/20.
//  Copyright © 2020 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import UIKit

class EMUIUtils {
    class func loadView(_ viewXIBName: String) -> UIView? {
        if let xibs = Bundle.main.loadNibNamed(viewXIBName, owner: nil, options: nil) {
            return (xibs.first as? UIView)
        }

        return nil
    }

    class func loadViewController(_ controllerName: String, storyBoardName: String?) -> UIViewController? {
        if storyBoardName == nil {
            // Try to get from XIB file
            return UIViewController(nibName: controllerName, bundle: nil)
        } else {
            let storyBoard = UIStoryboard(name: storyBoardName!, bundle: nil)
            return (storyBoard.instantiateViewController(withIdentifier: controllerName) as UIViewController?)
        }
    }

    class func loadInitialViewController(inStoryboad storyBoardName: String?) -> UIViewController? {
        guard let storyBoardName = storyBoardName else {
            return nil
        }

        let storyBoard = UIStoryboard(name: storyBoardName, bundle: nil)
        return storyBoard.instantiateInitialViewController()
    }
}

#endif
