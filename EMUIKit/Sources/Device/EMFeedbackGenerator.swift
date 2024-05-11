//
//  EMNotificationFeedbackGenerator.swift
//  ezSafe
//
//  Created by Nguyen Ngoc Tam on 15/05/2021.
//  Copyright © 2021 Logi. All rights reserved.
//

#if canImport(UIKit)

import Foundation
import AudioToolbox
import UIKit

public class EMBaseFeedbackGenerator {
    func prepare() {
        // override in subclass
    }

    func canTriggerFeedback() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return true
        }

        return false
    }

    /// This is support old device <= iPhone 6s
    fileprivate func triggerOldFeedback() {
        AudioServicesPlaySystemSound(1519)
        AudioServicesPlaySystemSound(1520)
        AudioServicesPlaySystemSound(1521)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    /// Check if this is new iOS device >= 7
    /// - Returns: true if this is iOS device >= 7
    fileprivate func canTriggerNewFeedbackGenerator() -> Bool {
        if UIDevice.current.isIPhone6s || UIDevice.current.isIPhone6sPlus || UIDevice.current.isIPhoneSE {
            return false
        }

        return true
    }
}

public enum EMNotificationFeedbackType {
    case warning
    case succes
    case error
}

public class EMNotificationFeedbackGenerator: EMBaseFeedbackGenerator {
    private var feedbackGenerator: UINotificationFeedbackGenerator!

    public override init() {
        feedbackGenerator = UINotificationFeedbackGenerator()
    }

    public override func prepare() {
        guard canTriggerFeedback(), canTriggerNewFeedbackGenerator() else {
            return
        }

        feedbackGenerator.prepare()
    }

    public func triggerFeedback(type: EMNotificationFeedbackType) {
        switch type {
        case .warning:
            triggerWarningFeedback()
        case .succes:
            triggerSuccessFeedback()
        case .error:
            triggerErrorFeedback()
        }
    }

    public func triggerErrorFeedback() {
        guard canTriggerNewFeedbackGenerator() else {
            triggerOldFeedback()
            return
        }

        feedbackGenerator.notificationOccurred(.error)
    }

    public func triggerWarningFeedback() {
        guard canTriggerNewFeedbackGenerator() else {
            triggerOldFeedback()
            return
        }

        feedbackGenerator.notificationOccurred(.warning)
    }

    public func triggerSuccessFeedback() {
        guard canTriggerNewFeedbackGenerator() else {
            triggerOldFeedback()
            return
        }

        feedbackGenerator.notificationOccurred(.success)
    }
}

public class EMImpactFeedbackGenerator: EMBaseFeedbackGenerator {
    private var feedbackGenerator: UIImpactFeedbackGenerator!

    public override init() {
        feedbackGenerator = UIImpactFeedbackGenerator()
    }

    public override func prepare() {
        guard canTriggerFeedback(), canTriggerNewFeedbackGenerator() else {
            return
        }

        feedbackGenerator.prepare()
    }

    public func triggerFeedback() {
        guard canTriggerNewFeedbackGenerator() else {
            triggerOldFeedback()
            return
        }

        feedbackGenerator.impactOccurred()
    }
}

public class EMSelectionFeedbackGenerator: EMBaseFeedbackGenerator {
    private var feedbackGenerator: UISelectionFeedbackGenerator!

    public override init() {
        feedbackGenerator = UISelectionFeedbackGenerator()
    }

    public override func prepare() {
        guard canTriggerFeedback(), canTriggerNewFeedbackGenerator() else {
            return
        }

        feedbackGenerator.prepare()
    }

    public func triggerFeedback() {
        guard canTriggerNewFeedbackGenerator() else {
            triggerOldFeedback()
            return
        }

        feedbackGenerator.selectionChanged()
    }
}

#endif
