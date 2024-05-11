//
//  HightlightButton.swift
//  AskApp
//
//  Created by Tam Nguyen Ngoc on 8/20/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import EMFoundation

open class EMHightlightButton: UIButton {

    private var hightlightLayer: CALayer!

    var hightlightColor: UIColor? = UIColor.black {
        didSet {
            self.hightlightLayer.backgroundColor = self.hightlightColor?.cgColor
        }
    }

    @IBInspectable var hightlightLayerOpacity: Double = 0.1
    @IBInspectable var disableHighlightEffect: Bool = false

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.initHighlightButton()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initHighlightButton()
    }

    open override func awakeFromNib() {
        super.awakeFromNib()

        self.initHighlightButton()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        guard let _ = hightlightLayer else {
            return
        }

        var layerRect = hightlightLayer.frame
        layerRect.size.width = self.frame.size.width
        layerRect.size.height = self.frame.size.height
        hightlightLayer.frame = layerRect
        hightlightLayer.cornerRadius = self.layer.cornerRadius
    }

    func setImage(_ image: UIImage?, forState state: UIControl.State, renderTemplateMode renderTemplate: Bool) {
        if image?.renderingMode != UIImage.RenderingMode.alwaysTemplate && state == UIControl.State() && renderTemplate {
            super.setImage(image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: state)
        } else {
            super.setImage(image, for: state)
        }
    }

    // MARK: Support methods

    private func initHighlightButton() {
        if self.hightlightLayer != nil {
            return
        }

        hightlightLayer = CALayer()
        hightlightLayer.backgroundColor = self.hightlightColor?.cgColor

        // Default hide hightlight layer
        hightlightLayer.opacity = 0

        layer.addSublayer(self.hightlightLayer)
        hightlightLayer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
    }

    func displayHightlightLayerAnimated() {
        if disableHighlightEffect {
            return
        }

        let opacityAniamtion = CABasicAnimation(keyPath: "opacity")
        opacityAniamtion.fromValue = 0
        opacityAniamtion.toValue = hightlightLayerOpacity

        let groupAnimations = CAAnimationGroup()
        groupAnimations.duration = 0.1
        groupAnimations.isRemovedOnCompletion = false
        groupAnimations.fillMode = CAMediaTimingFillMode.forwards
        groupAnimations.timingFunction = CAMediaTimingFunction(name: convertToCAMediaTimingFunctionName("linear"))
        groupAnimations.animations = [opacityAniamtion]

        self.hightlightLayer?.add(groupAnimations, forKey: "display.animations")
    }

    func hideHightlightLayerAnimated() {
        if disableHighlightEffect {
            return
        }

        let opacityAniamtion = CABasicAnimation(keyPath: "opacity")
        opacityAniamtion.fromValue = hightlightLayerOpacity
        opacityAniamtion.toValue = 0

        let groupAnimations = CAAnimationGroup()
        groupAnimations.duration = 0.1
        groupAnimations.isRemovedOnCompletion = true
        groupAnimations.fillMode = CAMediaTimingFillMode.backwards
        groupAnimations.timingFunction = CAMediaTimingFunction(name: convertToCAMediaTimingFunctionName("linear"))
        groupAnimations.animations = [opacityAniamtion]
        groupAnimations.delegate = self

        hightlightLayer?.add(groupAnimations, forKey: nil)
    }

    // MARK: Override touch events

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        // Show hightlight layer with animated
        displayHightlightLayerAnimated()
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        // Hide hightlight layer
        EMDispatchUtils.dispatchAfterDelay(0.15, queue: DispatchQueue.main) { [weak self] in
            self?.hideHightlightLayerAnimated()
        }
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        // Hide hightlight layer
        EMDispatchUtils.dispatchAfterDelay(0.15, queue: DispatchQueue.main) { [weak self] in
            self?.hideHightlightLayerAnimated()
        }
    }
}

extension EMHightlightButton: CAAnimationDelegate {
    public func animationDidStart(_ anim: CAAnimation) {
        hightlightLayer?.removeAnimation(forKey: "display.animations")
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToCAMediaTimingFunctionName(_ input: String) -> CAMediaTimingFunctionName {
	return CAMediaTimingFunctionName(rawValue: input)
}

#endif
