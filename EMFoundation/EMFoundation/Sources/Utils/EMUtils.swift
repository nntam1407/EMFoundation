//
//  Utils.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 9/7/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import Foundation

public class EMUtils: NSObject {
    public class func uuidString() -> String {
        let uuid = UUID()
        return uuid.uuidString.lowercased()
    }
}

public extension EMUtils {
    class func createSentToEmailURL(email: String) -> URL? {
        let mailTo = "mailto:\(email)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: mailTo)

        return url
    }

    class func createPhoneCallURL(phoneNumber: String) -> URL? {
        guard phoneNumber.count > 0, let url = URL(string: "telprompt://".appending(phoneNumber)) else {
            return nil
        }

        return url
    }
}
