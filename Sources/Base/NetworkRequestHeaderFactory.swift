//  Copyright © 2020 Andreas Link. All rights reserved.

import UIKit

internal enum NetworkRequestHeaderFactory {
    static func makeHeaders(for method: HttpMethod) -> [HttpHeaderField: String] {
        var headers: [HttpHeaderField: String] = [
            .acceptLanguage: Locale.autoupdatingCurrent.languageCode ?? "de",
            .accept: "application/json"
        ]

        if [.post, .patch, .put].contains(method) {
            headers[.contentType] = "application/json"
        }

        return headers
    }
}
