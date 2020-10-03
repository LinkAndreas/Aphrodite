//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

/**
 The blueprint of a `ParameterEncoding`.

 In most cases, the `JSONParameterEncoding` and `URLParameterEncoding` should suffice.
 Still,  custom encodings are realized by conforming to this protocol.
 - Note: Adapted from: https://github.com/Alamofire/Alamofire/blob/master/Source/ParameterEncoding.swift
 */
public protocol ParameterEncoding {
    /**
     Encodes the given parameters using this encoding and attaches the encoded parameters to the given `URLRequest`

     - Parameters:
      - request: The `URLRequest` the encoded paramters should be attached to.
      - parameters: The parameters to be encoded. If `nil` no parameters will be encoded and the unmodified request is returned.
     - Returns: The modified `URLRequest` that results from attaching the encoded parameters to the given `URLRequest`
     */
    func encode(_ urlRequest: URLRequest, with parameters: [String: Any]?) throws -> URLRequest
}
