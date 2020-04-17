//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

enum ApiError: Error {
    case unauthorized(HTTPURLResponse)
    case notFound(HTTPURLResponse)
    case forbidden(HTTPURLResponse)
    case underlying(HTTPURLResponse, Error)
    case client(HTTPURLResponse)
    case server(HTTPURLResponse)
    case decoding(DecodingError)
    case encoding(EncodingError)
    case serviceCancelled
    case notConnectedToInternet
    case unexpected

    var httpUrlRepsonse: HTTPURLResponse? {
        switch self {
        case let .unauthorized(response):
            return response

        case let .notFound(response):
            return response

        case let .forbidden(response):
            return response

        case let .underlying(response, _):
            return response

        default:
            return nil
        }
    }
}
