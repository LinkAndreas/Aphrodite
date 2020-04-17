//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

extension Dictionary where Key == HttpHeaderField, Value == String {
    /// - Returns: string representation of the http header fields
    var rawRepresentation: [String: String] {
        var result: [String: String] = [:]
        forEach { key, value in
            result[key.rawValue] = value
        }

        return result
    }
}
