//
//  Sound.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

struct Sound {
    
    let id: String
    let title: String
    let image: UIImage
    
    
    init(id: String, title: String, image: UIImage) {
        self.id = id
        self.title = title
        self.image = image
    }
}
