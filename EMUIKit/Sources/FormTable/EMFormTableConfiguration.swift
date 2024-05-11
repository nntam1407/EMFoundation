//
//  EMFormTableConfiguration.swift
//  EMUIKit
//
//  Created by Tam Nguyen on 18/10/2023.
//
#if canImport(UIKit)

import Foundation
import UIKit

public class EMFormTableLocalizationConfig {
    public var doneLocalized: String = "Done"

    public static var shared: EMFormTableLocalizationConfig {
        EMFormTableConfiguration.shared.localization
    }
}

public class EMFormTableTextViewCellConfig {
    public var backgroundColor: UIColor?
    public var titleFont: UIFont = .systemFont(ofSize: 12, weight: .regular)
    public var titleTextColor: UIColor = .secondaryLabel

    public var textFont: UIFont = .systemFont(ofSize: 15, weight: .regular)
    public var textColor: UIColor = .black

    public static var shared: EMFormTableTextViewCellConfig {
        EMFormTableConfiguration.shared.textViewCell
    }
}

public class EMFormTableTextFieldCellConfig {
    public var backgroundColor: UIColor?
    public var titleFont: UIFont = .systemFont(ofSize: 12, weight: .regular)
    public var titleTextColor: UIColor = .secondaryLabel

    public var textFont: UIFont = .systemFont(ofSize: 15, weight: .regular)
    public var textColor: UIColor = .black
    
    public static var shared: EMFormTableTextFieldCellConfig {
        EMFormTableConfiguration.shared.textFieldCell
    }
}

public class EMFormTableSwitchCellConfig {
    public var backgroundColor: UIColor?
    public var titleFont: UIFont = .systemFont(ofSize: 15, weight: .regular)
    public var titleTextColor: UIColor = .black

    public static var shared: EMFormTableSwitchCellConfig {
        EMFormTableConfiguration.shared.switchCell
    }
}

public class EMFormTableAddRowCellConfig {
    public var backgroundColor: UIColor?
    public var titleLabelFont: UIFont = .systemFont(ofSize: 15, weight: .regular)
    public var titleTextColor: UIColor = .black
    public var iconImage: UIImage? = .init(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24.0))

    public static var shared: EMFormTableAddRowCellConfig {
        EMFormTableConfiguration.shared.addRowCell
    }
}

public class EMFormTableCheckBoxCellConfig {
    public var backgroundColor: UIColor?
    public var checkedIconTintColor: UIColor = .systemBlue
    public var checkedIconImage: UIImage? = .init(systemName: "checkmark")
    public var titleFont: UIFont = .systemFont(ofSize: 15, weight: .regular)
    public var titleTextColor: UIColor = .black

    public var subtitleFont: UIFont = .systemFont(ofSize: 15, weight: .regular)
    public var subtitleTextColor: UIColor = .secondaryLabel

    public static var shared: EMFormTableCheckBoxCellConfig {
        EMFormTableConfiguration.shared.checkBoxCell
    }
}

public class EMFormTableLabelCellConfig {
    public var backgroundColor: UIColor?
    public var titleTextColor: UIColor = .black
    public var titleAlignment: NSTextAlignment = .left
    public var titleFont: UIFont = .systemFont(ofSize: 15, weight: .regular)

    public var secondaryTextColor: UIColor = .secondaryLabel
    public var secondaryTextAlignment: NSTextAlignment = .right
    public var secondaryTextFont: UIFont = .systemFont(ofSize: 15, weight: .regular)

    public var selectionStyle: EMFormTableViewCellSelectionStyle = .gray

    public static var shared: EMFormTableLabelCellConfig {
        EMFormTableConfiguration.shared.labelCell
    }
}

public class EMFormTableConfiguration {
    public lazy var localization: EMFormTableLocalizationConfig = .init()

    public lazy var textViewCell: EMFormTableTextViewCellConfig = .init()

    public lazy var textFieldCell: EMFormTableTextFieldCellConfig = .init()

    public lazy var switchCell: EMFormTableSwitchCellConfig = .init()

    public lazy var addRowCell: EMFormTableAddRowCellConfig = .init()

    public lazy var checkBoxCell: EMFormTableCheckBoxCellConfig = .init()

    public lazy var labelCell: EMFormTableLabelCellConfig = .init()

    public static let shared: EMFormTableConfiguration = .init()
}

#endif
