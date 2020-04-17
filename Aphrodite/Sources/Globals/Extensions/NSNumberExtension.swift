//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

extension NSNumber {
    var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
