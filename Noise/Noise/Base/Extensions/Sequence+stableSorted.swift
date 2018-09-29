//
//  Sequence+stableSorted.swift
//  Noise
//
//  Created by Michael Fröhlich on 30.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

extension Sequence {
    func stableSorted(
        by areInIncreasingOrder: (Element, Element) throws -> Bool)
        rethrows -> [Element]
    {
        return try enumerated()
            .sorted { a, b -> Bool in
                try areInIncreasingOrder(a.element, b.element) ||
                    (a.offset < b.offset && !areInIncreasingOrder(b.element, a.element))
            }
            .map { $0.element }
    }
}
