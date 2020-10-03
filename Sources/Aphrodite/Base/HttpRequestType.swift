//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

/// A network call's request type
public enum HttpRequestType {
    /// A plain request without any data
    case plainRequest
    /// A request including data in it's body
    case requestWithData(Data)
    /**
     A request including encoded parameters in it's body.

     Supported encodings are `JSONParameterEncoding`, as well as `URLParameterEncoding`.
     Custom encodings can be implemented by conforming to the `ParameterEncoding` protocol.
     */
    case requestWithParameters(parameters: [String: Any], encoding: ParameterEncoding)
}
