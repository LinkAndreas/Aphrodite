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

    var task: HttpTask {
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

    func testRequest() {
        let client: Aphrodite<MockDomainErrorFactory> = .init()
        client
            .request(MockTarget.mockEndpoint)
            .sink(
                receiveCompletion: { _ in }, 
                receiveValue: { }
            )
            .store(in: &cancellables)
    }

    func testRequestData() {
        let client: Aphrodite<MockDomainErrorFactory> = .init()
        client
            .requestData(MockTarget.mockEndpoint)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

    func testRequestModel() {
        let client: Aphrodite<MockDomainErrorFactory> = .init()
        client
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
        let client: Aphrodite<MockDomainErrorFactory> = .init()
        client
            .requestMappedModel(MockTarget.mockEndpoint, mapper: MapperMock.map)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { model in }
            )
            .store(in: &cancellables)
    }
}
