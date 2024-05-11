//
//  UIButtonDownloadExtension.swift
//  AskApp
//
//  Created by Tam Nguyen on 8/7/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import EMFoundation

extension UIButton {

    // MARK: Download image methods

    func setImage(imageURL: String,
                  defaultImage: UIImage?,
                  forState state: UIControl.State,
                  progressBlock: EMDownloadItem.ProgressHandler?,
                  completed completedBlock: ((_ image: UIImage?) -> Void)?) {

        // First should set default image for state
        self.setImage(defaultImage, for: state)

        EMHttpClient.shared.downloadImage(urlString: imageURL, progress: progressBlock) { [weak self] urlString, result in
            DispatchQueue.main.async {
                guard let self, urlString == imageURL else {
                    return
                }
                
                switch result {
                case .success(let image):
                    self.setImage(image, for: state)
                    completedBlock?(image)
                case .failure(let error):
                    DLog("Cannot download image: \(error)")
                    self.setImage(nil, for: state)
                    completedBlock?(nil)
                }
            }
        }
    }

    func setImage(
        imageURL: String,
        defaultImage: UIImage?,
        forState state: UIControl.State
    ) {
        self.setImage(
            imageURL: imageURL,
            defaultImage: defaultImage,
            forState: state,
            progressBlock: nil,
            completed: nil
        )
    }
}

#endif
