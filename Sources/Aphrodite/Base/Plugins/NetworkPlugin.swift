//  Copyright © 2020 Andreas Link. All rights reserved.

import Combine
import Foundation

public protocol NetworkPlugin {
    func prepare(_ request: URLRequest, target: NetworkTarget) -> AnyPublisher<URLRequest, Never>
    func willSend(_ request: URLRequest, target: NetworkTarget)
    func didReceive(_ result: Result<NetworkResponse, AphroditeError>, target: NetworkTarget)
}

public extension NetworkPlugin {
    func prepare(_ request: URLRequest, target: NetworkTarget) -> AnyPublisher<URLRequest, Never> {
        return Just(request).eraseToAnyPublisher()
    }

    func willSend(_ request: URLRequest, target: NetworkTarget) { /* Optional */ }
    func didReceive(_ result: Result<NetworkResponse, AphroditeError>, target: NetworkTarget) { /* Optional */ }
}
