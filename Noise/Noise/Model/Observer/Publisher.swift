//
//  Observable.swift
//  Noise
//
//  Created by Michael Fröhlich on 02.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

protocol Publisher {
    
    associatedtype T
    
    /**
     * An id that identifies the Publisher.
    **/
    var id: String { get }

    func subscribe<S: Subscriber>(_ subscriber: S)
    func unsubscribe<S: Subscriber>(_ subscriber: S)
    func notify()
}
