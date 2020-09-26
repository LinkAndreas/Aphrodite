//  Copyright © 2020 Andreas Link. All rights reserved.

import Combine
import Foundation

/// A generic network client build on top of NSURLSession and Combine
final public class Aphrodite<DomainErrorFactory: AphroditeDomainErrorFactory> {
    /// The plugin manager used by Aphrodite to intercept the preparation and result of each network call
    private let pluginManager: NetworkPluginManager
    /// A set of references to each cancellable operation
    private let cancellables: Set<AnyCancellable> = .init()

    /**
     Initializes a new network client using the given plugins.

     - Parameter plugins: The network plugins that be executed during request preparation as well as response reception
     - Returns: A generic network client using the given plugins.
     */
    public init(plugins: [NetworkPluginType: [NetworkPlugin]] = [:]) {
        self.pluginManager = .init(plugins: plugins)
    }

    /**
     Calls the given network target and notifies the subscriber when the call succeeded or failed (incl. domain error).

     The publisher publishes when the task completes, or terminates with the error if the task failed.

     - Parameter target: The network target to be called.
     - Returns: A publisher that wraps the network request for the given target.
     */
    public func request<T: NetworkTarget>(_ target: T) -> AnyPublisher<Void, DomainErrorFactory.AphroditeDomainError> {
        return makeAndExecuteRequest(for: target)
            .tryMap { result in
                switch result {
                case .success:
                    return ()

                case let .failure(error):
                    throw error
                }
            }
            .mapError(AphroditeErrorFactory.make)
            .mapError(DomainErrorFactory.make)
            .eraseToAnyPublisher()
    }

    /**
    Calls the given network target and notifies the subscriber when the call succeeded (incl. response data) or failed (incl. domain error).

    The publisher publishes data when the task completes, or terminates with the error if the task failed.

    - Parameter target: The network target to be called.
    - Returns: A publisher that wraps the network request for the given target.
    */
    public func requestData<T: NetworkTarget>(
        _ target: T
    ) -> AnyPublisher<Data, DomainErrorFactory.AphroditeDomainError> {
        return makeAndExecuteRequest(for: target)
            .tryMap { result in
                switch result {
                case let .success(response):
                    return response.data

                case let .failure(error):
                    throw error
                }
            }
            .mapError(AphroditeErrorFactory.make)
            .mapError(DomainErrorFactory.make)
            .eraseToAnyPublisher()
    }

    /**
    Calls the given network target and notifies the subscriber when the call succeeded (incl. response data) or failed (incl. domain error).

    The publisher publishes data when the task completes, or terminates with the error if the task failed.

    - Parameter target: The network target to be called.
    - Returns: A publisher that wraps the network request for the given target.
    */
    public func requestModel<T: NetworkTarget, Model: Decodable>(
        _ target: T
    ) -> AnyPublisher<Model, DomainErrorFactory.AphroditeDomainError> {
        let identity: (Model) -> Model = { $0 }

        return requestMappedModel(target, mapper: identity)
    }

    /**
    Calls the given network target and notifies the subscriber when the call succeeded (incl. mapped response data) or failed (incl. domain error).

    The publisher publishes data when the task completes, or terminates with the error if the task failed.

    - Parameters:
     - target: The network target to be called.
     - mapper: A function mapping the response entity to the target model.
    - Returns: A publisher that wraps the network request for the given target.
    */
    public func requestMappedModel<T: NetworkTarget, Entity: Decodable, Model>(
        _ target: T,
        mapper: @escaping (Entity) -> Model
    ) -> AnyPublisher<Model, DomainErrorFactory.AphroditeDomainError> {
        return makeAndExecuteRequest(for: target)
            .tryMap { result in
                switch result {
                case let .success(response):
                    do {
                        return try JSONDecoder.default.decode(Entity.self, from: response.data)
                    } catch {
                        let typeDescription: String = .init(describing: Entity.self)
                        NSLog("Couldn't decode model of type \(typeDescription), with error: \(error)")
                        if let decodingError: DecodingError = error as? DecodingError {
                            throw AphroditeError.decoding(response.httpUrlResponse, response.data, decodingError)
                        } else {
                            throw error
                        }
                    }

                case let .failure(error):
                    throw error
                }
            }
            .map(mapper)
            .mapError(AphroditeErrorFactory.make)
            .mapError(DomainErrorFactory.make)
            .eraseToAnyPublisher()
    }
}

extension Aphrodite {
    /**
    Creates a network request for the given target and executes it.

    The publisher publishes the result of the network request, or terminates with an error if the request creation failed.

    - Parameter target: The network target to be called.
    - Returns: A publisher that wraps the result of the network request for the given target.
    */
    private func makeAndExecuteRequest(
        for target: NetworkTarget
    ) -> AnyPublisher<Result<NetworkResponse, AphroditeError>, Never> {
        let result: Result<URLRequest, AphroditeError> = URLRequestFactory.makeUrlRequest(from: target)

        switch result {
        case let .success(request):
            return execute(request, for: target)

        case let .failure(error):
            return Just(.failure(error)).eraseToAnyPublisher()
        }
    }

    /**
    Executes the given request for the given target and notifies the subscriber when the request succeeded (incl. network response) or failed (incl. error).

    The publisher publishes the result of the network request, or terminates with an error if the request execution failed.

    - Parameters:
     - request: The network request to execute.
     - target: The network target to call.
    - Returns: A publisher that wraps the result of the network request for the given target.
    */
    private func execute(
        _ request: URLRequest,
        for target: NetworkTarget
    ) -> AnyPublisher<Result<NetworkResponse, AphroditeError>, Never> {
        return pluginManager.prepare(request, target: target)
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { self.pluginManager.willSend($0, target: target) })
            .setFailureType(to: URLError.self)
            .flatMap(URLSession.shared.dataTaskPublisher)
            .tryMap { data, response in
                guard let httpUrlResponse = response as? HTTPURLResponse else { throw AphroditeError.unexpected }

                if let error: AphroditeError = AphroditeErrorFactory.make(from: httpUrlResponse, data: data) {
                    throw error
                } else {
                    let networkResponse: NetworkResponse = .init(httpUrlResponse: httpUrlResponse, data: data)
                    return .success(networkResponse)
                }
            }
            .mapError(AphroditeErrorFactory.make)
            .catch { Just(.failure($0)) }
            .receive(on: RunLoop.main)
            .handleEvents(
                receiveOutput: { self.pluginManager.didReceive($0, target: target) },
                receiveCancel: { self.pluginManager.didReceive(.failure(.serviceCancelled), target: target) }
            )
            .eraseToAnyPublisher()
    }
}
