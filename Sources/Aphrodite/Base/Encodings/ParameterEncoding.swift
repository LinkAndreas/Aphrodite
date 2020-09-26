//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

// Adapted from: https://github.com/Alamofire/Alamofire/blob/master/Source/ParameterEncoding.swift
public protocol ParameterEncoding {
    func encode(_ urlRequest: URLRequest, with parameters: [String: Any]?) throws -> URLRequest
}
