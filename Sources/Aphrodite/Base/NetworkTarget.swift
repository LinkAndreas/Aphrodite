//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

public protocol NetworkTarget {
    var baseUrl: String { get }
    var usedPlugins: [NetworkPluginType] { get }
    var requestTimeoutInterval: TimeInterval { get }
    var path: String { get }
    var method: HttpMethod { get }
    var task: HttpTask { get }
    var headers: [HttpHeaderField: String] { get }
}

public extension NetworkTarget {
    var baseURL: URL {
        guard let url = URL(string: baseUrl) else { fatalError("Please ensure to provide a valid base url.") }

        return url
    }

    var usedPlugins: [NetworkPluginType] { [.universal] }

    var headers: [HttpHeaderField: String] {
        return NetworkRequestHeaderFactory.makeHeaders(for: method)
    }
}
