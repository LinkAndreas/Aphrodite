//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

// Reference: https://github.com/Alamofire/Alamofire/blob/master/Source/ParameterEncoding.swift
struct URLParameterEncoding: ParameterEncoding {
    enum Destination {
        case methodDependent
        case queryString
        case httpBody

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

    enum ArrayEncoding {
        case brackets
        case noBrackets

        func encode(key: String) -> String {
            switch self {
            case .brackets:
                return "\(key)[]"

            case .noBrackets:
                return key
            }
        }
    }

    enum BoolEncoding {
        case numeric
        case literal

        func encode(value: Bool) -> String {
            switch self {
            case .numeric:
                return value ? "1" : "0"

            case .literal:
                return value ? "true" : "false"
            }
        }
    }

    static let `default`: URLParameterEncoding = .init()
    static let queryString: URLParameterEncoding = .init(destination: .queryString)
    static let httpBody: URLParameterEncoding = .init(destination: .httpBody)

    let destination: Destination
    let arrayEncoding: ArrayEncoding
    let boolEncoding: BoolEncoding

    init(
        destination: Destination = .methodDependent,
        arrayEncoding: ArrayEncoding = .brackets,
        boolEncoding: BoolEncoding = .numeric
    ) {
        self.destination = destination
        self.arrayEncoding = arrayEncoding
        self.boolEncoding = boolEncoding
    }

    func encode(_ request: URLRequest, with parameters: [String: Any]?) throws -> URLRequest {
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

    func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
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

    func escape(_ string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowedRfc3986) ?? string
    }

    func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []

        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }

        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
}
