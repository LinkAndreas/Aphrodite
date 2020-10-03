//  Copyright © 2020 Andreas Link. All rights reserved.

import Combine
import Foundation

/// A blueprint of a network plugin used by the Network Plugin Manager. Network Plugins can modify and intercept each network call,
public protocol NetworkPlugin {
    /// The target scope of the network plugin, e.g., a univeral plugin applies to all targets
    var targetScope: NetworkPluginTargetScope { get }

    /**
     Modifies the network request before it is sent.

     - Parameters:
        - request: The `URLRequest` that can be modified before it is sent
        - target: The `target` of the network request specifying the base url, path, time-out interval, method, headers and scope of the target.
     - Returns: A publisher that emits as soon as the request preperation is done.
     */
    func prepare(_ request: URLRequest, target: NetworkTarget) -> AnyPublisher<URLRequest, Never>

    /**
     Notifies the network plugin right before the network request is sent.

     - Parameters:
        - request: The `URLRequest` that will be sent.
        - target: The `target` of the network request specifying the base url, path, time-out interval, method, headers and scope of the target.
     */
    func willSend(_ request: URLRequest, target: NetworkTarget)

    /**
     Notifies the network plugin that a network response was received.

     - Parameters:
        - result: The `result` of the call including the `NetworkResponse` if the request succeeded or an `AphroditeError` if it failed.
        - target: The `target` of the network request specifying the base url, path, time-out interval, method, headers and scope of the target.
     */
    func didReceive(_ result: Result<NetworkResponse, AphroditeError>, target: NetworkTarget)
}

/// Default implementations for network plugin requirements
public extension NetworkPlugin {
    var targetScope: NetworkPluginTargetScope { .universal }

    func prepare(_ request: URLRequest, target: NetworkTarget) -> AnyPublisher<URLRequest, Never> {
        return Just(request).eraseToAnyPublisher()
    }

    func willSend(_ request: URLRequest, target: NetworkTarget) { /* Optional */ }
    func didReceive(_ result: Result<NetworkResponse, AphroditeError>, target: NetworkTarget) { /* Optional */ }
}
