//
//  Serializable.swift
//  Noise
//
//  Created by Michael Fröhlich on 02.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

protocol Serializable {
    
    init?(from dict: Dictionary<String, String>)
    func toDictionary() -> Dictionary<String, String>
    
}
