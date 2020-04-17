//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

struct NetworkResponse: Equatable {
    var httpUrlResponse: HTTPURLResponse
    var data: Data

    var statusCode: Int { return httpUrlResponse.statusCode }
    var headerFields: [AnyHashable: Any] { return httpUrlResponse.allHeaderFields }
}
