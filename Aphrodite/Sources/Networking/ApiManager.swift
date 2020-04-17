//  Copyright © 2020 Andreas Link. All rights reserved.

import Combine
import Foundation

final class ApiManager {
    static let shared: ApiManager = .init()

    private init() { /* Singleton */ }

    private func makeAndExecuteRequest(for target: NetworkTarget) -> AnyPublisher<NetworkResponse, ApiError> {
        let result: Result<URLRequest, ApiError> = URLRequestFactory.makeUrlRequest(from: target)

        switch result {
        case let .success(request):
            return execute(request, for: target)

        case let .failure(error):
            return Fail<NetworkResponse, ApiError>(error: error).eraseToAnyPublisher()
        }
    }

    private func execute(_ request: URLRequest, for target: NetworkTarget) -> AnyPublisher<NetworkResponse, ApiError> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpUrlResponse = response as? HTTPURLResponse else {
                    throw ApiError.unexpected
                }

                let networkResponse: NetworkResponse = .init(httpUrlResponse: httpUrlResponse, data: data)

                if let apiError = ApiErrorFactory.make(from: networkResponse) {
                    throw apiError
                }

                return networkResponse
            }
            .mapError(ApiErrorFactory.make)
            .eraseToAnyPublisher()
    }
}

extension ApiManager {
    func call<T: NetworkTarget>(_ target: T) -> AnyPublisher<Void, DomainError> {
        return makeAndExecuteRequest(for: target)
            .map { _ in () }
            .mapError(DomainErrorFactory.make)
            .eraseToAnyPublisher()
    }

    func call<T: NetworkTarget>(_ target: T) -> AnyPublisher<Data, DomainError> {
        return makeAndExecuteRequest(for: target)
            .map { $0.data }
            .mapError(DomainErrorFactory.make)
            .eraseToAnyPublisher()
    }

    func call<T: NetworkTarget, Entity: Decodable, Model>(
        _ target: T,
        mapper: @escaping (Entity) -> Model
    ) -> AnyPublisher<Model, DomainError> {
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
            .mapError(ApiErrorFactory.make)
            .mapError(DomainErrorFactory.make)
            .map(mapper)
            .eraseToAnyPublisher()
    }
}
