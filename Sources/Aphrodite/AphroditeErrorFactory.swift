//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

internal enum AphroditeErrorFactory {
    static func make(from response: NetworkResponse) -> AphroditeError? {
        let statusCode: Int = response.httpUrlResponse.statusCode
        switch statusCode {
        case 401:
            return AphroditeError.unauthorized(response.httpUrlResponse)

        case 403:
            return AphroditeError.forbidden(response.httpUrlResponse)

        case 404:
            return AphroditeError.notFound(response.httpUrlResponse)

        case 405 ..< 500:
            return AphroditeError.client(response.httpUrlResponse, statusCode)

        case 500 ..< 600:
            return AphroditeError.server(response.httpUrlResponse, statusCode)

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

        switch error as? URLError {
        case let urlError? where urlError.code == .cancelled:
            return .serviceCancelled

        case let urlError? where urlError.code == .notConnectedToInternet:
            return .notConnectedToInternet

        default:
            return .unexpected
        }
    }
}
