//
//  ImageScrollView.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 2/6/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import UIKit

class EMImageScrollView: UIScrollView, UIScrollViewDelegate {

    struct Constans {
        static let defaultMaxZoom = 2.0
    }

    private var imageView: UIImageView!

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) {
        super.init(frame: frame)

        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        decelerationRate = UIScrollView.DecelerationRate.normal
        delegate = self
        maximumZoomScale = Constans.defaultMaxZoom

        imageView = UIImageView()
        addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        print("\(String(describing: self)) deinit")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if minimumZoomScale == 0 {
            resetZoomeScaleForImageView()
        }

        // Center image view
        let boundSize = bounds.size
        var frameToCenter = imageView.frame

        // Center horizoltally
        if frameToCenter.size.width < boundSize.width {
            frameToCenter.origin.x = (boundSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }

        // Center vertically
        if frameToCenter.size.height < boundSize.height {
            frameToCenter.origin.y = (boundSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }

        // Set frame for image view
        imageView.frame = frameToCenter
        imageView.contentScaleFactor = 1.0

        if let image = imageView.image {
            let isMinimumZoom = zoomScale == minimumZoomScale

            minimumZoomScale = minScaleForImageSize(image.size)
            zoomScale = isMinimumZoom ? minimumZoomScale : zoomScale
        }
    }

    // MARK: UIScrollView's delegates

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        guard let _ = imageView.superview else {
            return nil
        }

        return self.imageView
    }

    // MARK: Support methods

    private func minScaleForImageSize(_ imageSize: CGSize) -> CGFloat {
        let boundSize = bounds.size

        // Calculate min scale value
        let xScale = boundSize.width / imageSize.width
        let yScale = boundSize.height / imageSize.height

        return min(xScale, yScale)
    }

    private func resetZoomeScaleForImageView() {
        guard let image = imageView.image else {
            return
        }

        // Set zoome scale default is 1. Then re-add imageView
        zoomScale = 1.0
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)

        contentSize = image.size
        minimumZoomScale = minScaleForImageSize(image.size)

        // Set current scale is minium
        zoomScale = minimumZoomScale
    }

    // MARK: Public method

    func displayImage(_ image: UIImage?) {
        self.displayImage(image, fadeEffect: false)
    }

    func displayImage(_ image: UIImage?, fadeEffect: Bool) {
        guard let image = image else {
            self.imageView.image = nil
            return
        }

        imageView.image = image
        resetZoomeScaleForImageView()

        if fadeEffect {
            self.imageView.alpha = 0

            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.imageView.alpha = 1
            })
        }
    }
}

#endif
