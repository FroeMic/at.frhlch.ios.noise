//
//  Mixtape.swift
//  Noise
//
//  Created by Michael Fröhlich on 02.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation
import AFDateHelper
import UIKit

struct Mixtape {
    
    var id: String
    var title: String
    var detailDescription: String?
    private (set) var imageFilePath: String?
    var sounds: [Sound] {
        return _sounds.keys.flatMap { _sounds[$0] }
    }
    
    private var _sounds: [String: Sound]
    private var _image: UIImage?
    
    init?(managedMixtape: ManagedMixtape) {
        guard let id = managedMixtape.uuid else {
            return nil
        }
        guard let title = managedMixtape.title else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.detailDescription = managedMixtape.detailDescription
        self.imageFilePath = managedMixtape.imageFilePath
        self._sounds = [:]
        
        // unwrap the stored sounds
        if let mixtapeSounds = managedMixtape.sounds {
            for case let mixtapeSound as ManagedMixtapeSound in mixtapeSounds  {
                if let sound = Sound(managedMixtapeSound: mixtapeSound) {
                    _sounds[sound.id] = sound
                }
            }
        }

        setImage() 
    }
    
    var image: UIImage? {
        get {
            return _image
        }
        set(image) {
            if let image = image  {
                let filename = id + ".png"
                image.saveImage(name: filename)
                imageFilePath = filename
            } else {
                imageFilePath = nil
            }
            setImage()
        }
    }
    
    mutating func set(sounds: [Sound]) {
        var _sounds: [String: Sound] = [:]
        for sound in sounds {
            _sounds[sound.id] = sound
        }
        self._sounds = _sounds
    }
    
    mutating func add(sound: Sound) {
        add(sound: sound)
    }
    
    mutating func remove(sound: Sound) {
        _sounds[sound.id] = nil
    }
    
    mutating func update(sound: Sound) {
        _sounds[sound.id] = sound
    }
    
    private mutating func setImage() {
        if let imageFilePath = self.imageFilePath {
            _image = UIImage(fromFile: imageFilePath)
        } else {
            _image = nil
        }
    }

}
