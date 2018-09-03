//
//  Mixtape.swift
//  Noise
//
//  Created by Michael Fröhlich on 02.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

struct Mixtape {
    
    let id: String
    let title: String
    let sounds: [Sound]
    
    init(id: String, title: String, sounds: [Sound]) {
        self.id = id
        self.title = title
        self.sounds = sounds
    }
    
}

extension Mixtape: Identifiable {
    
}

extension Mixtape: Serializable {
    
    init?(from dict: Dictionary<String, String>) {
        
        guard let id = dict["id"] else {
            return nil
        }
        guard let title = dict["title"] else {
            return nil
        }
        guard let soundIDStrings = dict["soundIDs"]?.components(separatedBy: "|") else {
                return nil
        }
        guard let soundVolumeStrings = dict["soundVolumes"]?.components(separatedBy: "|") else {
                return nil
        }
        
        var volumes: [Float] = []
        for volumeString in soundVolumeStrings {
            guard let volume = Float(volumeString) else {
                return nil
            }
            volumes.append(volume)
        }
        
        guard soundIDStrings.count == soundVolumeStrings.count else {
            return nil
        }
        
        var sounds: [Sound] =  []
        for (index, id) in soundIDStrings.enumerated() {
            guard let originalSound = Injection.soundRepository.get(id: id) else {
                return nil
            }
            sounds.append(originalSound.with(volume: volumes[index]))
        }
        
        self.init(id: id, title: title, sounds: sounds)
    }
    
    func toDictionary() -> Dictionary<String, String> {
        var dict: Dictionary<String, String> = [:]
        
        dict["id"] = id
        dict["title"] = title
        dict["soundIDs"] = sounds.map { $0.id }.joined(separator: "|")
        dict["soundVolumes"] = sounds.map { String(format:"%f", $0.volume) }.joined(separator: "|")
        
        return dict
    }
    
}
