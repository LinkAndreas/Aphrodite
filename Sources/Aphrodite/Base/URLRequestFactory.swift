//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

/// The factory responsible for creating url requests.
internal enum URLRequestFactory {
    /**
     Creates an `URLRequest` for a given target.

     Produces either an `URLRequest` or indicates that the creation failed using an `AphroditeError`.

     - Parameter target: The target the `URLRequest` should be created for
     - Returns: The result of the url request creation, i.e., either the generated `URLRequest` or an `AphroditeError` indicating that the creation failed.
     */
    static func makeUrlRequest(from target: NetworkTarget) -> Result<URLRequest, AphroditeError> {
        var request: URLRequest = .init(url: .init(target: target))
        request.method = target.method
        request.allHTTPHeaderFields = target.headers.rawRepresentation
        request.timeoutInterval = target.requestTimeoutInterval

        switch target.requestType {
        case .plainRequest:
            break

        case let .requestWithData(data):
            request.httpBody = data

        case let .requestWithParameters(parameters: parameters, encoding: encoding):
            do {
                request = try encoding.encode(request, with: parameters)
            } catch {
                guard let encodingError = error as? EncodingError else { return .failure(.unexpected) }

                return .failure(.encoding(encodingError))
            }
        }

        return .success(request)
    }
}
