//
//  UIImageViewDownloadExtension.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 2/3/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import EMFoundation

extension UIImageView {
    struct Constaints {
        static var objcAssociationImageViewCurrentDownloadingUrlKey: UInt8 = 2
        static var objcAssociationImageViewCurrentDownloadingHighlightUrlKey: UInt8 = 3
    }

    /// Save current downloading image URL. We will use this value to make sure display final image after decoded right with image URL. Because we will decoded image after download in background, so it will take long time and while wating, maybe have other image URL
    private var currentDownloadingImageURLString: String? {
        get {
            return objc_getAssociatedObject(self, &Constaints.objcAssociationImageViewCurrentDownloadingUrlKey) as? String
        } set {
            objc_setAssociatedObject(self, &Constaints.objcAssociationImageViewCurrentDownloadingUrlKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    private var currentDownloadingHighlightImageURLString: String? {
        get {
            return objc_getAssociatedObject(self, &Constaints.objcAssociationImageViewCurrentDownloadingHighlightUrlKey) as? String
        } set {
            objc_setAssociatedObject(self, &Constaints.objcAssociationImageViewCurrentDownloadingHighlightUrlKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    private func runFadeAnimation() {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.25

        self.layer.removeAnimation(forKey: kCATransition)
        self.layer.add(transition, forKey: kCATransition)
    }

    /**
     Function set image from URL for this image view
     We will use memory address for blocksIdentifer
     */
    func setImageURL(imageURL: String?,
                     highlightImageURL: String?,
                     defaultImage: UIImage?,
                     progressBlock: EMDownloadItem.ProgressHandler?,
                     completed: ((_ image: UIImage?) -> Void)?) {

        // Set default image
        self.image = defaultImage
        self.currentDownloadingImageURLString = imageURL
        self.currentDownloadingHighlightImageURLString = highlightImageURL

        if let imageURL = imageURL {
            EMHttpClient.shared.downloadImage(urlString: imageURL, progress: progressBlock) { [weak self] urlString, result in
                DispatchQueue.main.async {
                    guard let self, urlString == self.currentDownloadingImageURLString else {
                        return
                    }

                    switch result {
                    case .success(let image):
                        self.runFadeAnimation()
                        self.image = image
                        completed?(image)
                    case .failure(let error):
                        DLog("Cannot download image: \(error)")
                        self.image = defaultImage
                        completed?(nil)
                    }
                }
            }
        } else {
            completed?(nil)
        }

        // Try to set hightlight image
        if let highlightImageURL = highlightImageURL {
            EMHttpClient.shared.downloadImage(urlString: highlightImageURL, progress: progressBlock) { [weak self] urlString, result in
                DispatchQueue.main.async {
                    guard let self, urlString == self.currentDownloadingHighlightImageURLString else {
                        return
                    }

                    switch result {
                    case .success(let image):
                        self.highlightedImage = image
                    case .failure(let error):
                        DLog("Cannot download image: \(error)")
                        self.highlightedImage = nil
                        completed?(nil)
                    }
                }
            }
        } else {
            self.highlightedImage = nil
        }
    }

    func setImageURL(imageURL: String?) {
        self.setImageURL(imageURL: imageURL, highlightImageURL: nil, defaultImage: nil, progressBlock: nil, completed: nil)
    }

    func setImageURL(imageURL: String?, defaultImage: UIImage?) {
        self.setImageURL(imageURL: imageURL, highlightImageURL: nil, defaultImage: defaultImage, progressBlock: nil, completed: nil)
    }

    func stopDownloadingImage() {
        if let currentURL = self.currentDownloadingImageURLString {
            EMHttpClient.shared.cancelDownload(urlString: currentURL)
        }
    }
}

#endif
