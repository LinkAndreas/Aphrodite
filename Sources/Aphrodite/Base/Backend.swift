//  Copyright © 2020 Andreas Link. All rights reserved.

import Foundation

public protocol Backend {
    var identifier: BackendIdentifier { get }
    var baseUrl: String { get }
}

extension Backend {
    var baseURL: URL {
        guard let url = URL(string: baseUrl) else {
            fatalError("The ")
        }

        return url
    }
}
