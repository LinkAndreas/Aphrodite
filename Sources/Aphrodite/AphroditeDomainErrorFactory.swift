//  Copyright © 2020 Andreas Link. All rights reserved.

/// A blueprint including the requirements an AphroditeDomainErrorFactory must fulfill
public protocol AphroditeDomainErrorFactory {
    /// The domain error type an AphroditeError is mapped to
    associatedtype DomainError: Error

    /// The function responsible for transforming an AphroditeError into the associated DomainError
    static func make(from error: AphroditeError) -> DomainError
}
