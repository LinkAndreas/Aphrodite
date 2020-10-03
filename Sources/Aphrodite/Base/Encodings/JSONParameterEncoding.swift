//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

/**
 A `JSONParameterEncoding` used to encode data as JSON parameters.

 - Note: Adapted from: https://github.com/Alamofire/Alamofire/blob/master/Source/ParameterEncoding.swift
 */
public struct JSONParameterEncoding: ParameterEncoding {
    /// The default `JSONParameterEncoding` that does not include additional writing options.
    public static let `default`: JSONParameterEncoding = .init()
    /// A `JSONParameterEncoding` that ensures a human readable structure.
    public static let prettyPrinted: JSONParameterEncoding = .init(options: .prettyPrinted)

    /// The options for writing JSON data
    let options: JSONSerialization.WritingOptions

    /**
     Initializes an `JSONParameterEncoding` given the options for writing JSON data.

     - Parameter options: The  options for writing JSON data
     - Returns: The `JSONParameterEncoding` for the options for writing JSON data.
     */
    init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }

    /**
     Encodes the given parameters using this encoding and attaches the encoded parameters to the given `URLRequest`

     - Parameters:
      - request: The `URLRequest` the encoded paramters should be attached to.
      - parameters: The parameters to be encoded. If `nil` no parameters will be encoded and the unmodified request is returned.
     - Returns: The modified `URLRequest` that results from attaching the encoded parameters to the given `URLRequest`
     */
    public func encode(_ request: URLRequest, with parameters: [String: Any]?) throws -> URLRequest {
        guard let parameters = parameters else { return request }

        var modifiedRequest: URLRequest = request

        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: options)
            if modifiedRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                modifiedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

            modifiedRequest.httpBody = data
        } catch {
            guard let encodingError = error as? EncodingError else {
                throw AphroditeError.unexpected
            }

            throw AphroditeError.encoding(encodingError)
        }

        return modifiedRequest
    }
}
