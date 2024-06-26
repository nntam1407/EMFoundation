//
//  CircleLoadingView.swift
//  ChatApp
//
//  Created by Tam Nguyen Ngoc on 2/14/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import UIKit

open class EMCircleLoadingView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    public var value: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    /**
     * The color which is used to draw the progress indicator. Use UIAppearance to style according your needs.
     * Default is gray color
     */
    public var color: UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }

    public var strokeBehindLayerColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    /**
        The stroke width ratio is used to calculate the circle thickness regarding the actual size of the progress indicator view. When setting this, strokeWidth is ignored.
        Default is 0.15
    */
    public var strokeWidthPercent: CGFloat = 0.15 {
        didSet {
            setNeedsDisplay()
        }
    }

    required public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Override methods

    public override func draw(_ rect: CGRect) {
        // Draw this view
        let contextRef = UIGraphicsGetCurrentContext()

        let center = CGPoint(x: rect.size.width / 2, y: rect.size.height / 2)
        let minSize = min(rect.size.width, rect.size.height)
        let lineWidth = minSize * self.strokeWidthPercent
        let radius = (minSize - lineWidth) / 2
        let endAngle = CGFloat(Double.pi) * (self.value * 2)

        contextRef?.saveGState()
        contextRef?.translateBy(x: center.x, y: center.y)
        contextRef?.rotate(by: -CGFloat(Double.pi) * 0.5)

        contextRef?.setLineWidth(lineWidth)
        contextRef?.setLineCap(CGLineCap.round)

        // "Full" Background Circle:
        contextRef?.beginPath()
        contextRef?.addArc(center: CGPoint.zero, radius: radius, startAngle: 0, endAngle: 2 * CGFloat(Double.pi), clockwise: false)
        contextRef?.setStrokeColor(self.strokeBehindLayerColor != nil ? self.strokeBehindLayerColor!.cgColor : self.color.withAlphaComponent(0.1).cgColor)
        contextRef?.strokePath()

        // Progress Arc:
        contextRef?.beginPath()
        contextRef?.addArc(center: CGPoint.zero, radius: radius, startAngle: 0, endAngle: endAngle, clockwise: false)
        contextRef?.setStrokeColor(self.color.withAlphaComponent(0.9).cgColor)
        contextRef?.strokePath()

        contextRef?.restoreGState()
    }
}

#endif
