//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

internal enum AphroditeErrorFactory {
    static func make(from httpUrlResponse: HTTPURLResponse) -> AphroditeError? {
        let statusCode: Int = httpUrlResponse.statusCode
        switch statusCode {
        case 401:
            return AphroditeError.unauthorized(httpUrlResponse)

        case 403:
            return AphroditeError.forbidden(httpUrlResponse)

        case 404:
            return AphroditeError.notFound(httpUrlResponse)

        case 405 ..< 500:
            return AphroditeError.client(httpUrlResponse, statusCode)

        case 500 ..< 600:
            return AphroditeError.server(httpUrlResponse, statusCode)

        default:
            return nil
        }
    }

    static func make(from error: Error) -> AphroditeError {
        if let apiError = error as? AphroditeError {
            return apiError
        }

        if let decodingError: DecodingError = error as? DecodingError {
            return AphroditeError.decoding(decodingError)
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
