//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

/// NSNumber Extensions
internal extension NSNumber {
    /// Indicates whether the underlying type is boolean.
    var isBool: Bool { CFBooleanGetTypeID() == CFGetTypeID(self) }
}
