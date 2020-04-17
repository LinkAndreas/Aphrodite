//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

enum DomainErrorFactory {
    static func make(from error: ApiError) -> DomainError {
        return .unexpected
    }
}
