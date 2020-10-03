//  Copyright © 2020 Andreas Link. All rights reserved.

/// The scope of a network plugin
public struct NetworkPluginTargetScope: RawRepresentable, Equatable, Hashable {
    public var rawValue: String

    /**
     Initializes an `NetworkPluginTargetScope` for a given `identifier`.

     - Parameter identifier: The identifier of the network plugin target scope
     - Returns: The `NetworkPluginTargetScope` for the given `identifier`.
     */
    public init(identifier: String) {
        self.rawValue = identifier
    }

    /**
     Initializes an `NetworkPluginTargetScope` for a given `rawValue`.

     - Parameter rawValue: The rawValue of the network plugin target scope
     - Returns: The `NetworkPluginTargetScope` for the given `rawValue`.
     */
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Default network plugin target scopes
public extension NetworkPluginTargetScope {
    /// A network plugin target scope applying to all targets.
    static let universal: NetworkPluginTargetScope = .init(identifier: "universal")
}
