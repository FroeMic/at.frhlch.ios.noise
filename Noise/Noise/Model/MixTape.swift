//
//  MixTape.swift
//  Noise
//
//  Created by Michael Fröhlich on 02.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

struct MixTape {
    
    let id: String
    let title: String
    let sounds: [Sound]
    
    init(id: String, title: String, sounds: [Sound]) {
        self.id = id
        self.title = title
        self.sounds = sounds
    }
    
}
