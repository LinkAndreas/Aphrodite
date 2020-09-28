//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

/// A data structrue representing the response for a network call
public struct NetworkResponse {
    /// The `HTTPURLResponse` of the network response.
    public var httpUrlResponse: HTTPURLResponse
    /// The response data
    public var data: Data

    /// The Http status code associated with the network response.
    public var statusCode: Int { httpUrlResponse.statusCode }
    /// The headerFields associated with the netowrk response.
    public var headerFields: NSDictionary { httpUrlResponse.allHeaderFields as NSDictionary }

    /**
        Initializes a network response given the `HTTPURLResponse` as well as the response `Data`.

        - Returns: The `NetworkResponse` made from the `HTTPURLResponse` as well as the response `Data`
     */
    public init(httpUrlResponse: HTTPURLResponse, data: Data) {
        self.httpUrlResponse = httpUrlResponse
        self.data = data
    }
}
