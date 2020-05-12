//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

internal extension NSNumber {
    var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
