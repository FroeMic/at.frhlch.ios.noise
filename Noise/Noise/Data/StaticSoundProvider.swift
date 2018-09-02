//
//  StaticSoundProvider.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class StaticSoundProvider: SoundProvider {
   
    let soundRepository = UDSoundRepository()
    
    var sounds: [Sound] {
        return soundRepository.getAll().map { $0.1 }
    }
    
    var defaultMixTap: MixTape {
        return MixTape(id: "", title: "Noise Ambient Sounds", sounds: sounds)
    }
    
    let mixTapes: [MixTape] = [
    
    ]
    
}
