//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

/// The factory responsible for creating the default headers for the given `HttpMethod`.
internal enum NetworkRequestHeaderFactory {
    /**
     Creates the default Http headers for the given `HttpMethod`.

     - Parameter method: The `HttpMethod` from which the default headers should be made from.
     - Returns: The default headers for the given `HttpMethod`.
     */
    static func makeHeaders(for method: HttpMethod) -> [HttpHeaderField: String] {
        var headers: [HttpHeaderField: String] = [.acceptLanguage: Locale.autoupdatingCurrent.languageCode ?? "de"]

        if [.post, .patch, .put].contains(method) {
            headers[.contentType] = "application/json"
        }

        return headers
    }
}
