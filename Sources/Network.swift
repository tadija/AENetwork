/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

open class Network {
    
    // MARK: Singleton
    
    public static let shared = Network(router: .shared, downloader: .shared)

    // MARK: Properties

    public let router: Router
    public let downloader: Downloader

    // MARK: Init
    
    public init(router: Router = .init(),
                downloader: Downloader = .init()) {
        self.router = router
        self.downloader = downloader
    }

}
