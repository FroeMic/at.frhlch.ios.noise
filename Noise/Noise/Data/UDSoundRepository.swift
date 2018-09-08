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
              title: "Autumn Rain",
              subtitle: "Thick drops of rain dumming to the ground",
              description: "Calm your mood with the sound of autumn rainfall. Hundreds of thick and heavy drops drum to the ground creating a soothing sound atmosphere.",
              imageName: "sound_heavy_rain",
              soundFile: "audio_rain_60s"),
        Sound(id: "2",
              title: "Berlin Coffee  Shop",
              subtitle: "Find yourself in a Berlin coffee shop buzzing with life",
              description: "Dive into the scenery of a Berlin coffee shop buzzing with energy. The pleasant smell of freshly brewed coffee hangs in the air while the busy chatter of people all around you blends in with the venue. Time to get to work.",
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
