//
//  HttpClientError.swift
//  ezSafe
//
//  Created by Tam Nguyen on 21/07/2022.
//  Copyright © 2022 Logi. All rights reserved.
//

import Foundation

extension NSError {
    class func createHttpClientCancelledError() -> NSError {
        NSError(domain: EMHttpClientErrorDomain, code: EMHttpClientErrorCode.cancelled.rawValue)
    }

    class func createHttpClientOtherError() -> NSError {
        NSError(domain: EMHttpClientErrorDomain, code: EMHttpClientErrorCode.other.rawValue)
    }

    class func createHttpClientInvalidURLError() -> NSError {
        NSError(domain: EMHttpClientErrorDomain, code: EMHttpClientErrorCode.invalidURL.rawValue)
    }

    class func createHttpClientExistingError() -> NSError {
        NSError(domain: EMHttpClientErrorDomain, code: EMHttpClientErrorCode.existing.rawValue)
    }

    class func createHttpClientFileNotFoundError() -> NSError {
        NSError(domain: EMHttpClientErrorDomain, code: EMHttpClientErrorCode.fileNotFound.rawValue)
    }

    class func createHttpClientCannotMoveFileError() -> NSError {
        NSError(domain: EMHttpClientErrorDomain, code: EMHttpClientErrorCode.cannotMoveFile.rawValue)
    }

    var isHttpClientError: Bool {
        return domain == EMHttpClientErrorDomain
    }

    var isHttpClientCancelledError: Bool {
        code == EMHttpClientErrorCode.cancelled.rawValue
    }
}
