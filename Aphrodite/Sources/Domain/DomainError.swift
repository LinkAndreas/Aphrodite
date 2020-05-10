//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

enum DomainError: Error {
    case unauthorized(HTTPURLResponse)
    case notFound(HTTPURLResponse)
    case forbidden(HTTPURLResponse)
    case underlying(HTTPURLResponse, Error)
    case client(HTTPURLResponse, StatusCode)
    case server(HTTPURLResponse, StatusCode)
    case decoding(DecodingError)
    case encoding(EncodingError)
    case serviceCancelled
    case notConnectedToInternet
    case unexpected
}
