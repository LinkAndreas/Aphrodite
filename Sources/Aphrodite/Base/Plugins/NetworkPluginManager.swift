//  Copyright © 2020 Andreas Link. All rights reserved.

import Combine
import Foundation

final class NetworkPluginManager: NetworkPlugin {
    /// The network plugins managed by the `NetworkPluginManager`.
    private let plugins: [NetworkPlugin]
    /// A set of references to each cancellable operation
    private var cancellables: Set<AnyCancellable> = .init()

    /**
     Initializes a `NetworkPluginManager` with the given network plugins.
     - Parameter plugins: The network plugins that are used by the `NetworkPluginManager`.
     - Returns: The `NetworkPluginManager` for the given network plugins.
     */
    init(plugins: [NetworkPlugin]) {
        self.plugins = plugins
    }

    /**
     Modifies the network request before it is sent.

     - Parameters:
        - request: The `URLRequest` that can be modified before it is sent
        - target: The `target` of the network request specifying the base url, path, time-out interval, method, headers and scope of the target.
     - Returns: A publisher that emits as soon as the request preperation is done.
     */
    func prepare(_ request: URLRequest, target: NetworkTarget) -> AnyPublisher<URLRequest, Never> {
        return Future<URLRequest, Never> { [unowned self] resolve in
            self.executeNextPluginIfNeeded(request: request, target: target, plugins: self.plugins) { request in
                resolve(.success(request))
            }
        }.eraseToAnyPublisher()
    }

    /**
     Notifies the network plugin right before the network request is sent.

     - Parameters:
        - request: The `URLRequest` that will be sent.
        - target: The `target` of the network request specifying the base url, path, time-out interval, method, headers and scope of the target.
     */
    func willSend(_ request: URLRequest, target: NetworkTarget) {
        plugins.forEach { plugin in
            guard target.scope.contains(plugin.targetScope) else { return }

            plugin.willSend(request, target: target)
        }
    }

    /**
     Notifies the network plugin that a network response was received.

     - Parameters:
        - result: The `result` of the call including the `NetworkResponse` if the request succeeded or an `AphroditeError` if it failed.
        - target: The `target` of the network request specifying the base url, path, time-out interval, method, headers and scope of the target.
     */
    func didReceive(_ result: Result<NetworkResponse, AphroditeError>, target: NetworkTarget) {
        plugins.forEach { plugin in
            guard target.scope.contains(plugin.targetScope) else { return }

            plugin.didReceive(result, target: target)
        }
    }
}

extension NetworkPluginManager {
    private func executeNextPluginIfNeeded(
        request: URLRequest,
        target: NetworkTarget,
        plugins: [NetworkPlugin],
        completion: @escaping (URLRequest) -> Void
    ) {
        guard let nextPlugin = plugins.first else {
            completion(request)
            return
        }

        nextPlugin.prepare(request, target: target).sink { [unowned self] request in
            let remainingPlugins: [NetworkPlugin] = [NetworkPlugin](plugins.dropFirst())
            self.executeNextPluginIfNeeded(
                request: request,
                target: target,
                plugins: remainingPlugins,
                completion: completion
            )
        }.store(in: &cancellables)
    }
}
