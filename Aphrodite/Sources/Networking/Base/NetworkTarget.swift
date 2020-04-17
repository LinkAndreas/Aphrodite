//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

protocol NetworkTarget {
    var baseURL: URL { get }
    var requestTimeoutInterval: TimeInterval { get }
    var path: String { get }
    var method: HttpMethod { get }
    var task: HttpTask { get }
    var headers: [HttpHeaderField: String] { get }
}

extension NetworkTarget {
    var headers: [HttpHeaderField: String] {
        return NetworkRequestHeaderFactory.makeHeaders(for: method)
    }
}
