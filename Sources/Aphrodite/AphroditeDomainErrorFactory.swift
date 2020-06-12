//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

public protocol AphroditeDomainErrorFactory {
    associatedtype AphroditeDomainError: Error

    static func make(from error: AphroditeError) -> AphroditeDomainError
}
