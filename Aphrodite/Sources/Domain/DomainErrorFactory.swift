//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

enum DomainErrorFactory {
    static func make(from error: ApiError) -> DomainError {
        switch error {
        case let .unauthorized(response):
            return .unauthorized(response)

        case let .notFound(response):
            return .notFound(response)

        case let .forbidden(response):
            return .forbidden(response)

        case let .underlying(response, error):
            return .underlying(response, error)

        case let .encoding(error):
            return .encoding(error)

        case let .decoding(error):
            return .decoding(error)

        case .serviceCancelled:
            return .serviceCancelled

        case .notConnectedToInternet:
            return .notConnectedToInternet

        default:
            return .unexpected
        }
    }

    static func make(from error: URLError) -> DomainError {
        switch error.code {
        case .cancelled:
            return .serviceCancelled

        case .notConnectedToInternet:
            return .notConnectedToInternet

        default:
            return .unexpected
        }
    }
}
