//  Copyright © 2020 Andreas Link. All rights reserved.

public struct HttpHeaderField: RawRepresentable, Equatable, Hashable {
    public var rawValue: String

    public init(identifier: String) {
        self.rawValue = identifier
    }

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension HttpHeaderField {
    static let acceptLanguage: HttpHeaderField = .init(identifier: "accept-language")
    static let contentType: HttpHeaderField = .init(identifier: "Content-Type")
    static let authorization: HttpHeaderField = .init(identifier: "Authorization")
}
