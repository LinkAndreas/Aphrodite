//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

/// JSONDecoder extensions
internal extension JSONDecoder {
    /**
    The default `JSONDecoder`.

    The default instance decodes data with `.base64` as well as dates in milliseconds.
    */
    static let `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .base64
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateInt = try container.decode(Int64.self)

            return Date(timeIntervalSince1970: TimeInterval(dateInt) / 1_000)
        }

        return decoder
    }()
}
