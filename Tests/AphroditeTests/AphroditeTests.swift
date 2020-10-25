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

struct MockUserInfoEntity: Codable {
    let name: String
}

struct MockUserInfo {
    let name: String
}

enum MockUserInfoModelMapper {
    static func make(from entity: MockUserInfoEntity) -> MockUserInfo {
        return .init(name: entity.name)
    }

    static func map(from model: MockUserInfo) -> MockUserInfoEntity {
        return .init(name: model.name)
    }
}

enum MockTarget: NetworkTarget {
    case mockEndpoint
    case createProfile(profileName: String)
    case register(MockUserInfo)

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

        case .register, .createProfile:
            return .post
        }
    }

    var requestType: HttpRequestType {
        switch self {
        case .mockEndpoint:
            return .plainRequest

        case let .createProfile(profileName):
            return .requestWithParameters(
                parameters: ["profileName": "\(profileName)"],
                encoding: JSONParameterEncoding()
            )

        case let .register(userInfo):
            return .requestWithData(from: userInfo, mapper: MockUserInfoModelMapper.map)
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

    func testRequestWithDataAttachment() {
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
