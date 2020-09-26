//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

internal enum URLRequestFactory {
    static func makeUrlRequest(from target: NetworkTarget) -> Result<URLRequest, AphroditeError> {
        var request: URLRequest = .init(url: .init(target: target))
        request.method = target.method
        request.allHTTPHeaderFields = target.headers.rawRepresentation
        request.timeoutInterval = target.requestTimeoutInterval

        switch target.task {
        case .requestPlain:
            break

        case let .requestData(data):
            request.httpBody = data

        case let .requestParameters(parameters: parameters, encoding: encoding):
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
