//
//  UDSoundRepository.swift
//  Noise
//
//  Created by Michael Fröhlich on 02.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

class UDSoundRepository: UserDefaultsRepository<Sound>, SoundRepository {
      
    private var defaultSounds: [Sound] = [
        Sound(id: "1",
              title: "Heavy Rain",
              subtitle: "Heavy rainfall in a land far away.",
              imageName: "sound_heavy_rain",
              soundFile: "audio_rain_60s"),
        Sound(id: "2",
              title: "Coffee Shop",
              subtitle: "Busy coffee shop chatter.",
              imageName: "sound_coffee_shop",
              soundFile: "audio_cafe_60s")
    ]
    
    init() {
        super.init(suite: "at.frhlch.ios.noise.sounds")
        
        let sounds = getAll()
        if sounds.count == 0 {
            reset()
        }
    }
    
    override func reset() {
        super.reset()
        
        for sound in defaultSounds {
            store(sound)
        }
        
    }
    
}
