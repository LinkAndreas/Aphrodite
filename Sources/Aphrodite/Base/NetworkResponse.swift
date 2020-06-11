//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

public struct NetworkResponse {
    var httpUrlResponse: HTTPURLResponse
    var data: Data
    var error: AphroditeError?

    var statusCode: Int { return httpUrlResponse.statusCode }
    var headerFields: [AnyHashable: Any] { return httpUrlResponse.allHeaderFields }
}
