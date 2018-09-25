//
//  AudioBundle.swift
//  Noise
//
//  Created by Michael Fröhlich on 25.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

struct AudioBundle {
    
    let id: String
    let displayTitle: String
    let artist: String
    let albumImage: UIImage?
    var sounds: [Sound]
    
    init(mixtape: Mixtape) {
        self.id = mixtape.id
        self.sounds = mixtape.sounds
        self.displayTitle = "Mixtape: " + mixtape.title
        self.artist = "Noise"
        self.albumImage = mixtape.image ?? UIImage(named: "placeholder_artwork")!
    }
    
    init(id: String, title: String, sounds: [Sound], artist: String = "Noise", image: UIImage? = nil) {
        self.id = id
        self.sounds = sounds
        self.displayTitle = title
        self.artist = artist
        self.albumImage = image ?? UIImage(named: "placeholder_artwork")!
    }
    
}
