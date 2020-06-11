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
            .map { _ in () }
            .mapError { F.make(from: $0, and: target) }
            .eraseToAnyPublisher()
    }

    public func call<T: NetworkTarget>(_ target: T) -> AnyPublisher<Data, F.AphroditeDomainError> {
        return makeAndExecuteRequest(for: target)
            .map { $0.data }
            .mapError { F.make(from: $0, and: target) }
            .eraseToAnyPublisher()
    }

    public func call<T: NetworkTarget, Entity: Decodable, Model>(
        _ target: T,
        mapper: @escaping (Entity) -> Model
    ) -> AnyPublisher<Model, F.AphroditeDomainError> {
        return makeAndExecuteRequest(for: target)
            .tryMap { response in
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
        }
        .mapError(AphroditeErrorFactory.make)
        .mapError { F.make(from: $0, and: target) }
        .map(mapper)
        .eraseToAnyPublisher()
    }
}

extension Aphrodite {
    private func makeAndExecuteRequest(for target: NetworkTarget) -> AnyPublisher<NetworkResponse, AphroditeError> {
        let result: Result<URLRequest, AphroditeError> = URLRequestFactory.makeUrlRequest(from: target)

        switch result {
        case let .success(request):
            return execute(request, for: target)

        case let .failure(error):
            return Fail<NetworkResponse, AphroditeError>(error: error).eraseToAnyPublisher()
        }
    }

    private func execute(
        _ request: URLRequest,
        for target: NetworkTarget
    ) -> AnyPublisher<NetworkResponse, AphroditeError> {
        return pluginManager.prepare(request, target: target)
            .handleEvents(receiveOutput: { self.pluginManager.willSend($0, target: target) })
            .setFailureType(to: URLError.self)
            .flatMap(URLSession.shared.dataTaskPublisher)
            .tryMap { data, response in
                guard let httpUrlResponse = response as? HTTPURLResponse else { throw AphroditeError.unexpected }

                return .init(httpUrlResponse: httpUrlResponse, data: data)
            }
            .mapError(AphroditeErrorFactory.make)
            .handleEvents(
                receiveOutput: { self.pluginManager.didReceive(.success($0), target: target) },
                receiveCompletion: { completion in
                    guard case let .failure(error) = completion else { return }

                    self.pluginManager.didReceive(.failure(error), target: target)
                },
                receiveCancel: { self.pluginManager.didReceive(.failure(.serviceCancelled), target: target) }
            )
            .eraseToAnyPublisher()
    }
}
