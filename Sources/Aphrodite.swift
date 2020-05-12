//  Copyright © 2020 Andreas Link. All rights reserved.

import Combine
import Foundation

final public class Aphrodite<DEF: DomainErrorFactory> {
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

public extension Aphrodite {
    func call<T: NetworkTarget>(_ target: T) -> AnyPublisher<Void, DEF.DomainError> {
        return makeAndExecuteRequest(for: target)
            .map { _ in () }
            .mapError(DEF.make)
            .eraseToAnyPublisher()
    }

    func call<T: NetworkTarget>(_ target: T) -> AnyPublisher<Data, DEF.DomainError> {
        return makeAndExecuteRequest(for: target)
            .map { $0.data }
            .mapError(DEF.make)
            .eraseToAnyPublisher()
    }

    func call<T: NetworkTarget, Entity: Decodable, Model>(
        _ target: T,
        mapper: @escaping (Entity) -> Model
    ) -> AnyPublisher<Model, DEF.DomainError> {
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
            .mapError(DEF.make)
            .map(mapper)
            .eraseToAnyPublisher()
    }
}
