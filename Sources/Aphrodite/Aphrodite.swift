//  Copyright © 2020 Andreas Link. All rights reserved.

import Combine
import Foundation

final public class Aphrodite<F: AphroditeDomainErrorFactory> {
    private var pluginManager: NetworkPluginManager
    private var cancellables: Set<AnyCancellable> = .init()

    public init(plugins: [NetworkPluginType: [NetworkPlugin]] = [:]) {
        self.pluginManager = .init(plugins: plugins)
    }

    public func call<T: NetworkTarget>(_ target: T) -> AnyPublisher<Void, F.AphroditeDomainError> {
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
            .mapError(F.make)
            .eraseToAnyPublisher()
    }

    public func call<T: NetworkTarget>(_ target: T) -> AnyPublisher<Data, F.AphroditeDomainError> {
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
            .mapError(F.make)
            .eraseToAnyPublisher()
    }

    public func call<T: NetworkTarget, Entity: Decodable, Model>(
        _ target: T,
        mapper: @escaping (Entity) -> Model
    ) -> AnyPublisher<Model, F.AphroditeDomainError> {
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
            .mapError(AphroditeErrorFactory.make)
            .mapError(F.make)
            .map(mapper)
            .eraseToAnyPublisher()
    }
}

extension Aphrodite {
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
            .catch { Just(.failure($0))}
            .receive(on: RunLoop.main)
            .handleEvents(
                receiveOutput: { self.pluginManager.didReceive($0, target: target) },
                receiveCancel: { self.pluginManager.didReceive(.failure(.serviceCancelled), target: target) }
            )
            .eraseToAnyPublisher()
    }
}
