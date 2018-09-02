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
    let subtitle: String
    let image: UIImage
    let soundFile: String
    let volume: Float
    
    var soundUrl: URL? {
        guard let path = Bundle.main.path(forResource: soundFile, ofType:"mp3") else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }
    
    init(id: String, title: String, subtitle: String,  image: UIImage, soundFile: String, volume: Float = 0.5) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.soundFile = soundFile
        self.volume = volume
    }
}
