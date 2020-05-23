//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

internal extension URL {
    init(target: NetworkTarget) {
        if target.path.isEmpty {
            self = target.backend.baseURL
        } else {
            self = target.backend.baseURL.appendingPathComponent(target.path)
        }
    }
}
