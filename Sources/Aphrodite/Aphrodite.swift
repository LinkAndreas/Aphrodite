//  Copyright © 2020 Andreas Link. All rights reserved.

import Combine
import Foundation

final public class Aphrodite<F: AphroditeDomainErrorFactory> {
    public init() { /* Public initializer */ }

    public func call<T: NetworkTarget>(_ target: T) -> AnyPublisher<Void, F.AphroditeDomainError> {
        return makeAndExecuteRequest(for: target)
            .map { _ in () }
            .mapError(F.make)
            .eraseToAnyPublisher()
    }

    public func call<T: NetworkTarget>(_ target: T) -> AnyPublisher<Data, F.AphroditeDomainError> {
        return makeAndExecuteRequest(for: target)
            .map { $0.data }
            .mapError(F.make)
            .eraseToAnyPublisher()
    }

    public func call<T: NetworkTarget, Entity: Decodable, Model>(
        _ target: T,
        mapper: @escaping (Entity) -> Model
    ) -> AnyPublisher<Model, F.AphroditeDomainError> {
        return makeAndExecuteRequest(for: target)
            .map { $0.data }
            .tryMap { data in
                do {
                    return try JSONDecoder.default.decode(Entity.self, from: data)
                } catch {
                    let typeDescription: String = .init(describing: Entity.self)
                    NSLog("Couldn't decode model of type \(typeDescription), with error: \(error)")
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
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpUrlResponse = response as? HTTPURLResponse else { throw AphroditeError.unexpected }

                let networkResponse: NetworkResponse = .init(httpUrlResponse: httpUrlResponse, data: data)

                if let apiError = AphroditeErrorFactory.make(from: networkResponse) {
                    throw apiError
                }

                return networkResponse
            }
            .mapError(AphroditeErrorFactory.make)
            .eraseToAnyPublisher()
    }
}