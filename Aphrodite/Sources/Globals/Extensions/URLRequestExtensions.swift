//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

extension URLRequest {
    var method: HttpMethod? {
        get { return httpMethod.flatMap(HttpMethod.init) }
        set { httpMethod = newValue?.rawValue }
    }
}
