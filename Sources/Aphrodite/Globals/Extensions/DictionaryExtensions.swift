//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

/// Dictionary extensions
internal extension Dictionary where Key == HttpHeaderField, Value == String {
    /// String representation of the http header fields
    var rawRepresentation: [String: String] {
        var result: [String: String] = [:]
        forEach { key, value in
            result[key.rawValue] = value
        }

        return result
    }
}
