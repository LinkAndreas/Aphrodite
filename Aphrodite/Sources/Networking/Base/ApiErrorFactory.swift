//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

enum ApiErrorFactory {
    static func make(from response: NetworkResponse) -> ApiError? {
        let statusCode: Int = response.httpUrlResponse.statusCode
        switch statusCode {
        case 401:
            return ApiError.unauthorized(response.httpUrlResponse)

        case 403:
            return ApiError.forbidden(response.httpUrlResponse)

        case 404:
            return ApiError.notFound(response.httpUrlResponse)

        case 405 ..< 500:
            return ApiError.client(response.httpUrlResponse, statusCode)

        case 500 ..< 600:
            return ApiError.server(response.httpUrlResponse, statusCode)

        default:
            return nil
        }
    }

    static func make(from error: Error) -> ApiError {
        if let apiError = error as? ApiError {
            return apiError
        }

        if let decodingError: DecodingError = error as? DecodingError {
            return ApiError.decoding(decodingError)
        }

        if let encodingError: EncodingError = error as? EncodingError {
            return ApiError.encoding(encodingError)
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
