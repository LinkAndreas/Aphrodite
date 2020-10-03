//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

/// URL Extensions
internal extension URL {
    /**
     Initializes an URL for the given target.

     The URL is made from the `baseURL` and `path`
     - Parameter target: The `target` the `url` should be made from.
     - Returns: The `url` made from the given target.
    */
    init(target: NetworkTarget) {
        if target.path.isEmpty {
            self = target.baseURL
        } else {
            self = target.baseURL.appendingPathComponent(target.path)
        }
    }
}
