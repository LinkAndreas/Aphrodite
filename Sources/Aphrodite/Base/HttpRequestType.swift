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

    /**
     A request that is built from mapping the given `model` to it's corresponding `entity`. The mapping is established using the `mapper` function.

     - Parameters:
        - model: The `model` that is mapped to it's corresponding `entity`.
        - encoder: The `JSONEncoder` to be used for the encoding.
        - mapper: The `mapper` function to transform the given `model` into it's corresponding `entity`.
     */
    public static func requestWithData<Model, Entity: Encodable>(
        from model: Model,
        encoder: JSONEncoder = .default,
        mapper: (Model) -> Entity
    ) -> Self {
        return requestWithData(from: mapper(model), encoder: encoder)
    }

    /**
     A request that encodes the given `entity` using the specified `JSONEncoder`

     - Parameters:
        - entity: The `entity` that is encoded using the `JSONEncoder`.
        - encoder: The `JSONEncoder` to be used for the encoding.
     */
    public static func requestWithData<Entity: Encodable>(
        from entity: Entity,
        encoder: JSONEncoder = .default
    ) -> Self {
        guard let jsonData = try? encoder.encode(entity) else { return .plainRequest }

        return .requestWithData(jsonData)
    }
}
