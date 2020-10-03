//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

/// URLReqest Extensions
internal extension URLRequest {
    /// The `HttpMethod` associated with this request.
    var method: HttpMethod? {
        get { return httpMethod.flatMap(HttpMethod.init) }
        set { httpMethod = newValue?.rawValue }
    }
}
