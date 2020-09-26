//  Copyright © 2020 Andreas Link. All rights reserved.

public protocol AphroditeDomainErrorFactory {
    associatedtype AphroditeDomainError: Error

    static func make(from error: AphroditeError) -> AphroditeDomainError
}
