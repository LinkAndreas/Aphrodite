import Combine
import XCTest
@testable import Aphrodite

enum MockDomainError: Error {
    case unexpected
}

enum MockDomainErrorFactory: AphroditeDomainErrorFactory {
    static func make(from error: AphroditeError) -> MockDomainError {
        return .unexpected
    }
}

enum MockTarget: NetworkTarget {
    case mockEndpoint

    var baseUrl: String {
        return "https://google.com"
    }

    var requestTimeoutInterval: TimeInterval {
        return 10
    }

    var path: String {
        return ""
    }

    var method: HttpMethod {
        switch self {
        case .mockEndpoint:
            return .get
        }
    }

    var requestType: HttpRequestType {
        switch self {
        case .mockEndpoint:
            return .plainRequest
        }
    }
}

struct EntityMock: Decodable {
    let name: String
}

struct ModelMock: Decodable {
    let name: String
}

enum MapperMock {
    static func map(entity: EntityMock) -> ModelMock {
        return .init(name: entity.name)
    }
}

final class AphroditeTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    private let API: AphroditeClient<MockDomainErrorFactory> = .init()

    func testRequest() {
        API
            .request(MockTarget.mockEndpoint)
            .sink(
                receiveCompletion: { _ in }, 
                receiveValue: { }
            )
            .store(in: &cancellables)
    }

    func testRequestData() {
        API
            .requestData(MockTarget.mockEndpoint)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

    func testRequestModel() {
        API
            .requestModel(MockTarget.mockEndpoint)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure:
                        return

                    case .finished:
                        return
                    }
                },
                receiveValue: { (model: ModelMock) in }
            )
            .store(in: &cancellables)
    }

    func testRequestMappedModel() {
        API
            .requestMappedModel(MockTarget.mockEndpoint, mapper: MapperMock.map)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { model in }
            )
            .store(in: &cancellables)
    }
}
