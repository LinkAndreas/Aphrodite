//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

internal extension URL {
    init(target: NetworkTarget) {
        if target.path.isEmpty {
            self = target.baseURL
        } else {
            self = target.baseURL.appendingPathComponent(target.path)
        }
    }
}
