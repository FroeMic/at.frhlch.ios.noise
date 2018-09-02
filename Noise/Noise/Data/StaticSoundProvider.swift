//
//  StaticSoundProvider.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class StaticSoundProvider: SoundProvider {
   
    let sounds: [Sound] = [
        Sound(id: "1", title: "Heavy Rain", image: UIImage(named: "sound_heavy_rain")!, soundFile: "audio_rain_60s"),
        Sound(id: "2", title: "Coffee Shop", image: UIImage(named: "sound_coffee_shop")!, soundFile: "audio_cafe_60s")
    ]
    
    var defaultMixTap: MixTape {
        return MixTape(id: "", title: "Noise Ambient Sounds", sounds: sounds)
    }
    
    let mixTapes: [MixTape] = [
    
    ]
    
}
