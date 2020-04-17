//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

enum HttpTask {
    case requestPlain
    case requestData(Data)
    case requestParameters(parameters: [String: Any], encoding: ParameterEncoding)
}
