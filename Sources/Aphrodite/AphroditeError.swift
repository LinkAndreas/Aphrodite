//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

public enum AphroditeError: Error {
    case unauthorized(HTTPURLResponse, Data)
    case notFound(HTTPURLResponse, Data)
    case forbidden(HTTPURLResponse, Data)
    case underlying(HTTPURLResponse, Data, Error)
    case client(HTTPURLResponse, Data, StatusCode)
    case server(HTTPURLResponse, Data, StatusCode)
    case decoding(HTTPURLResponse, Data, DecodingError)
    case encoding(EncodingError)
    case serviceCancelled
    case notConnectedToInternet
    case unexpected
}

extension AphroditeError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unauthorized:
            return "unauthorized"
        case .notFound:
            return "notFound"
        case .forbidden:
            return "forbidden"
        case .underlying:
            return "underlying"
        case .client:
            return "client"
        case .server:
            return "server"
        case .decoding:
            return "decoding"
        case .encoding:
            return "encoding"
        case .serviceCancelled:
            return "serviceCancelled"
        case .notConnectedToInternet:
            return "notConnectedToInternet"
        case .unexpected:
            return "unexpected"
        }
    }
}
