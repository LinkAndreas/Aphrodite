//  Copyright © 2020 Andreas Link. All rights reserved.

/// The type of a network plugin
public struct NetworkPluginType: RawRepresentable, Equatable, Hashable {
    public var rawValue: String

    /**
     Initializes an `NetworkPluginType` for a given `identifier`.

     - Parameter identifier: The identifier of the Http header field
     - Returns: The `NetworkPluginType` for the given `identifier`.
     */
    public init(identifier: String) {
        self.rawValue = identifier
    }

    /**
     Initializes an `NetworkPluginType` for a given `rawValue`.

     - Parameter rawValue: The rawValue of the network plugin type
     - Returns: The `NetworkPluginType` for the given `rawValue`.
     */
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Default network plugin types
public extension NetworkPluginType {
    /// A network plugin type applying to all targets.
    static let universal: NetworkPluginType = .init(identifier: "universal")
}
