//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

// Reference: https://github.com/Alamofire/Alamofire/blob/master/Source/ParameterEncoding.swift
struct JSONParameterEncoding: ParameterEncoding {
    static let `default`: JSONParameterEncoding = .init()
    static let prettyPrinted: JSONParameterEncoding = .init(options: .prettyPrinted)

    let options: JSONSerialization.WritingOptions

    init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }

    func encode(_ request: URLRequest, with parameters: [String: Any]?) throws -> URLRequest {
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
                throw ApiError.unexpected
            }

            throw ApiError.encoding(encodingError)
        }

        return modifiedRequest
    }
}
