//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

public struct NetworkResponse {
    public var httpUrlResponse: HTTPURLResponse
    public var data: Data

    public var statusCode: Int { return httpUrlResponse.statusCode }
    public var headerFields: [AnyHashable: Any] { return httpUrlResponse.allHeaderFields }

    public init(httpUrlResponse: HTTPURLResponse, data: Data) {
        self.httpUrlResponse = httpUrlResponse
        self.data = data
    }
}
