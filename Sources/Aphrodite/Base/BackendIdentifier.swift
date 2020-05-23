//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

public struct BackendIdentifier: RawRepresentable, Equatable {
    public var rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}
