//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation


/**
 A `ParameterEncoding` used to encode data as URL parameters.

 - Note: Adapted from: https://github.com/Alamofire/Alamofire/blob/master/Source/ParameterEncoding.swift
 */
public struct URLParameterEncoding: ParameterEncoding {
    /// The destination specifying whether the URL parameters should be attached to the query string or the request's body.
    public enum Destination {
        /// Parameters are attached to the queryString in case that `GET`, `HEAD` or `DELETE` is used. Otherwise, they are included in the request's body.
        case methodDependent
        /// Parameters are attached to the query string
        case queryString
        /// Parameters are attached to the HTTP request's body
        case httpBody

        /**
         States whether parameters should be encoded in the URL or not.

         - Parameter method: The HTTP method to be used for the method dependent determination
         - Returns: true iff the destination is queryString or the given Http method is either `GET`, `HEAD` or `DELETE`.
         */
        func encodesParametersInURL(for method: HttpMethod) -> Bool {
            switch self {
            case .methodDependent:
                return [.get, .head, .delete].contains(method)

            case .queryString:
                return true

            case .httpBody:
                return false
            }
        }
    }

    /// The type of encoding to be used for encoding Arrays
    public enum ArrayEncoding {
        /// Arrays are encoded using brackets, i.e., e.g., `arrayName[]`
        case brackets
        /// Arrays are encoded without brackets, i.e., e.g., `arrayName`
        case noBrackets

        /**
         Encodes the given key using either the bracket or noBracket notation.

         - Parameter key: The name of the array
         - Returns: The encoded array representation
         */
        func encode(key: String) -> String {
            switch self {
            case .brackets:
                return "\(key)[]"

            case .noBrackets:
                return key
            }
        }
    }

    /// The type of encoding to be used for booleans
    public enum BoolEncoding {
        /// Encodes the value as either `0` or `1`
        case numeric
        /// Encodes the value as either `true` or `false`
        case literal

        /**
         Encodes the given boolean using either the numeric or literal encoding

         - Parameter value: The value to be encoded.
         - Returns: The encoded bool representation
         */
        func encode(value: Bool) -> String {
            switch self {
            case .numeric:
                return value ? "1" : "0"

            case .literal:
                return value ? "true" : "false"
            }
        }
    }

    /// The default encoding using `.methodDependent` as destination, `.brackets` as array encoding and `.numeric` as boolean encoding.
    static let `default`: URLParameterEncoding = .init()
    /// Same as the default encoding, but using `queryString` as destination.
    static let queryString: URLParameterEncoding = .init(destination: .queryString)
    /// Same as the default encoding, but using `httpBody` as destination.
    static let httpBody: URLParameterEncoding = .init(destination: .httpBody)

    /// The destination of the encoding
    let destination: Destination
    /// The type of encoding to be used for encoding arrays.
    let arrayEncoding: ArrayEncoding
    /// The type of encoding to be used for encoding booleans.
    let boolEncoding: BoolEncoding

    /**
     Initializes an `URLParameterEncoding` given the destination as well as the array- and boolean ecoding type to be used.

     - Parameters:
      - destination: The destination of the encoding, i.e., either `.methodDependent`, `.queryString` or `.httpBody`
      - arrayEncoding: The type of encoding to be used for encoding arrays, i.e., either `.brackets` or `noBrackets`
      - boolEncoding: The type of encoding to be used for encoding booleans, i.e., either `.numeric` or `literal`
     - Returns: The `URLParameterEncoding` for the given destination and encodings.
     */
    public init(
        destination: Destination = .methodDependent,
        arrayEncoding: ArrayEncoding = .brackets,
        boolEncoding: BoolEncoding = .numeric
    ) {
        self.destination = destination
        self.arrayEncoding = arrayEncoding
        self.boolEncoding = boolEncoding
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

        if let method = modifiedRequest.method, destination.encodesParametersInURL(for: method) {
            guard let url = modifiedRequest.url else { throw AphroditeError.unexpected }

            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                urlComponents.percentEncodedQuery = percentEncodedQuery
                modifiedRequest.url = urlComponents.url
            }
        } else {
            if modifiedRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                modifiedRequest.setValue(
                    "application/x-www-form-urlencoded; charset=utf-8",
                    forHTTPHeaderField: "Content-Type"
                )
            }

            modifiedRequest.httpBody = Data(query(parameters).utf8)
        }

        return modifiedRequest
    }

    /**
     Generates query components for the given key and value. Query components for dictionaries and arrays are generated recursively.
     - Parameters:
      - key: The key of the parameter
      - value: The value of the parameter
     - Returns: Query components for the given key-value pair
     */
    private func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []

        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: arrayEncoding.encode(key: key), value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape(boolEncoding.encode(value: value.boolValue))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape(boolEncoding.encode(value: bool))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }

        return components
    }

    /**
     Encodes the given string according to the allowed characters as specified in RFC 3986

     - Parameter string: The string to be encoded
     - Returns: The encoded string
     */
    private func escape(_ string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowedRfc3986) ?? string
    }

    /**
     Generates the query string by combining its query components for the given parameters

     - Parameter parameters: The parameters that are encoded in the string
     - Returns: The encoded query string
     */
    private func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []

        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }

        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
}
