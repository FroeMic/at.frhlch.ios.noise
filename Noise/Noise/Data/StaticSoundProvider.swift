//
//  StaticSoundProvider.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class StaticSoundProvider: SoundProvider {
   
    var sounds: [Sound] = [
        Sound(id: "1", title: "Heavy Rain", image: UIImage(named: "sound_heavy_rain")!),
        Sound(id:"2", title: "Coffee Shop", image: UIImage(named: "sound_coffee_shop")!)
    ]
    
}
