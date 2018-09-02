//
//  Subscriber.swift
//  Noise
//
//  Created by Michael Fröhlich on 02.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

protocol Subscriber {
    
    associatedtype T
    
    /**
     * An id that identifies the Subscriber.
     **/
    var id: String { get }
    
    /**
     * Called by the subscribed publisher whenever an update occured.
     **/
    func update<T>(with newValue: T)
}
