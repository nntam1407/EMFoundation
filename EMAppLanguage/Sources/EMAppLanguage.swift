//
//  LanguageService.swift
//  FunnyApp
//
//  Created by Tam Nguyen on 1/26/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import Foundation

public protocol EMAppLanguageProtocol {
    var displayedAppLanguage: String? { get }
}

public class EMAppLanguage: EMAppLanguageProtocol {
    public var localizationLookupTableName = "Localizable"
    public var defaultLanguageSource = "en"

    public var displayedAppLanguage: String? {
        if #available(iOS 16, macOS 13, *) {
            guard let languageId = Locale.current.language.languageCode?.identifier else {
                return nil
            }
            return Locale.current.localizedString(forIdentifier: languageId)
        } else {
            guard let languageCode = Locale.current.languageCode else {
                return nil
            }

            return Locale.current.localizedString(forLanguageCode: languageCode)
        }
    }

    // MARK: Class methods

    public static let shared: EMAppLanguage = {
        EMAppLanguage()
    }()

    // MARK: - Public methods

    public func localized(key: String, defaultValue: String? = nil) -> String {
        var localized = NSLocalizedString(
            key,
            tableName: localizationLookupTableName,
            bundle: Bundle.main,
            value: defaultValue ?? "",
            comment: ""
        )

        if localized.isEmpty || localized == key {
            // Try to fetch from defaultLanguage source
            if let path = Bundle.main.path(forResource: defaultLanguageSource, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                localized = NSLocalizedString(
                    key,
                    tableName: localizationLookupTableName,
                    bundle: bundle,
                    comment: ""
                )
            }
        }

        // If still empty, then return key as an value
        if localized.isEmpty {
            localized = key
        }

        return localized
    }
}
