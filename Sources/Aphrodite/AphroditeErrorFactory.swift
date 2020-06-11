//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

internal enum AphroditeErrorFactory {
    static func make(from httpUrlResponse: HTTPURLResponse, data: Data) -> AphroditeError? {
        let statusCode: Int = httpUrlResponse.statusCode
        switch statusCode {
        case 401:
            return AphroditeError.unauthorized(httpUrlResponse, data)

        case 403:
            return AphroditeError.forbidden(httpUrlResponse, data)

        case 404:
            return AphroditeError.notFound(httpUrlResponse, data)

        case 405 ..< 500:
            return AphroditeError.client(httpUrlResponse, data, statusCode)

        case 500 ..< 600:
            return AphroditeError.server(httpUrlResponse, data, statusCode)

        default:
            return nil
        }
    }

    static func make(from error: Error) -> AphroditeError {
        if let apiError = error as? AphroditeError {
            return apiError
        }

        if let encodingError: EncodingError = error as? EncodingError {
            return AphroditeError.encoding(encodingError)
        }

        if let urlError: URLError = error as? URLError {
            switch urlError.code {
            case .cancelled:
                return .serviceCancelled

            case .notConnectedToInternet:
                return .notConnectedToInternet

            default:
                return .unexpected
            }
        }

        return .unexpected
    }
}
