//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

extension CharacterSet {
    /// Creates a CharacterSet from RFC 3986 allowed characters.
    /// Reference: https://github.com/Alamofire/Alamofire/blob/master/Source/URLEncodedFormEncoder.swift
    static let urlQueryAllowedRfc3986: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
    }()
}
