//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

public protocol DomainErrorFactory {
    associatedtype DomainError: Error

    static func make(from error: AphroditeError) -> DomainError
}
