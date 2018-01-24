//
//  String+Helpers.swift
//  AENetwork
//
//  Created by Marko Tadić on 1/24/18.
//

import Foundation

extension String {

    // MARK: Constants

    static let unavailable = "n/a"

    // MARK: Properties

    public var url: URL {
        return URL(string: self) ?? URL.invalid
    }

}
