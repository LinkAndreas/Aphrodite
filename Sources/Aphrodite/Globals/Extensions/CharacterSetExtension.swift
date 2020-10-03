//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

internal extension CharacterSet {
    /**
     The `CharacterSet` only including characters that are allowed in RFC 3986.

     - Note: Adapted from: https://github.com/Alamofire/Alamofire/blob/master/Source/URLEncodedFormEncoder.swift
     */
    static let urlQueryAllowedRfc3986: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
    }()
}
