//  Copyright © 2020 Andreas Link. All rights reserved.

/// A convenience type representing Http Header fields
public struct HttpHeaderField: RawRepresentable, Equatable, Hashable {
    public var rawValue: String

    /**
     Initializes an `HttpHeaderField` for a given `identifier`.

     - Parameter identifier: The identifier of the Http header field
     - Returns: The `HttpHeaderField` for the given `identifier`.
     */
    public init(identifier: String) {
        self.rawValue = identifier
    }

    /**
     Initializes an `HttpHeaderField` for a given `rawValue`.

     - Parameter rawValue: The rawValue of the Http header field
     - Returns: The `HttpHeaderField` for the given `rawValue`.
     */
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Default HttpHeaderFields
public extension HttpHeaderField {
    /// The header field indicating the language
    static let acceptLanguage: HttpHeaderField = .init(identifier: "accept-language")
    /// The header field indicating the content type
    static let contentType: HttpHeaderField = .init(identifier: "Content-Type")
    /// The header field indicating the authorization mechanism
    static let authorization: HttpHeaderField = .init(identifier: "Authorization")
}
