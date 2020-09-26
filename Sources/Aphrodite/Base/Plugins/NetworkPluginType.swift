//  Copyright © 2020 Andreas Link. All rights reserved.

public struct NetworkPluginType: RawRepresentable, Equatable, Hashable {
    public var rawValue: String

    public init(identifier: String) {
        self.rawValue = identifier
    }

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}
