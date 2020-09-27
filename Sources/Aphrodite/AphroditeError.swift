//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

/// The main error type of an Aphrodite client. Cases can be mapped to a dedicated domain error using an `AphroditeDomainErrorFactory`
public enum AphroditeError: Error {
    /// The error associated with the HTTP status code 401
    case unauthorized(HTTPURLResponse, Data)
    /// The error associated with the HTTP status code 403
    case forbidden(HTTPURLResponse, Data)
    /// The error associated with the HTTP status code 404
    case notFound(HTTPURLResponse, Data)
    /// The error associated with an HTTP status code in [405, 500)
    case client(HTTPURLResponse, Data, StatusCode)
    /// The error associated with an HTTP status code in [500, 600)
    case server(HTTPURLResponse, Data, StatusCode)
    /// The error associated with a decoding error
    case decoding(HTTPURLResponse, Data, DecodingError)
    /// The error associated with a encoding error
    case encoding(EncodingError)
    /// The error associated with the HTTP status code 404
    case underlying(HTTPURLResponse, Data, Error)
    /// The error wrapping all request related errors
    case serviceCancelled
    /// The error indicating that the client is not connected to the internet
    case notConnectedToInternet
    /// The error representing all unexpected errors
    case unexpected
}

extension AphroditeError: CustomStringConvertible {
    /// An human-readable description of each characteristic
    public var description: String {
        switch self {
        case .unauthorized:
            return "unauthorized"

        case .forbidden:
            return "forbidden"

        case .notFound:
            return "notFound"

        case .client:
            return "client"

        case .server:
            return "server"

        case .decoding:
            return "decoding"

        case .encoding:
            return "encoding"

        case .underlying:
            return "underlying"

        case .serviceCancelled:
            return "serviceCancelled"

        case .notConnectedToInternet:
            return "notConnectedToInternet"

        case .unexpected:
            return "unexpected"
        }
    }
}
