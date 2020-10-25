//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

/// JSONEncoder extensions
public extension JSONEncoder {
    /**
     The default `JSONEncoder`.

     The default instance encodes data with `.base64` as well as dates in milliseconds.
     */
    static let `default`: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.dateEncodingStrategy = .custom { date, encoder in
            let dateInt = Int64(date.timeIntervalSince1970 * 1_000)
            var container = encoder.singleValueContainer()
            try container.encode(dateInt)
        }

        return encoder
    }()
}
