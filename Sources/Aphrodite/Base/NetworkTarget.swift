//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

/// The blueprint of a `NetworkTarget`
public protocol NetworkTarget {
    /// The `baseUrl` of the target.
    var baseUrl: String { get }
    /// The scope of the target.
    var scope: [NetworkPluginTargetScope] { get }
    /// The maximum time interval until a network request for this target times out.
    var requestTimeoutInterval: TimeInterval { get }
    /// The path for this target. Combined with the `baseUrl` the `path` forms the endpoint's `url`
    var path: String { get }
    /// The `HttpMethod` to use for this target, e.g., `delete`, `get`, `post` or `put`.
    var method: HttpMethod { get }
    /// The requestType for this target, e.g., `plainRequest`, `requestWithData` or `requestWithParameters`.
    var requestType: HttpRequestType { get }
    /// The headers that are included for this target.
    var headers: [HttpHeaderField: String] { get }
}

/// NetworkTarget default implementations
public extension NetworkTarget {
    var baseURL: URL {
        guard let url = URL(string: baseUrl) else { fatalError("Please ensure to provide a valid base url.") }

        return url
    }

    var scope: [NetworkPluginTargetScope] { [.universal] }

    var headers: [HttpHeaderField: String] {
        return NetworkRequestHeaderFactory.makeHeaders(for: method)
    }
}
