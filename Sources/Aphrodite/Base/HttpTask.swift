//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

public enum HttpTask {
    case plainRequest
    case requestWithData(Data)
    case requestWithParameters(parameters: [String: Any], encoding: ParameterEncoding)
}
