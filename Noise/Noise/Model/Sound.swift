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
    let description: String
    let imageName: String
    let soundFile: String
    let volume: Float
   
    
    var soundUrl: URL? {
        guard let path = Bundle.main.path(forResource: soundFile, ofType:"mp3") else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }
    
    var image: UIImage {
        return UIImage(named: imageName) ?? UIImage()
    }
    
    init(id: String, title: String, subtitle: String, description: String, imageName: String, soundFile: String, volume: Float = 0.5) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.imageName = imageName
        self.soundFile = soundFile
        self.volume = volume
    }
    
    func with(volume: Float) -> Sound {
        return Sound(id: id,
             title: self.title,
             subtitle: self.subtitle,
             description: self.description,
             imageName: self.imageName,
             soundFile: self.soundFile,
             volume: volume)
    }
}

extension Sound: Equatable {

    static func ==(lhs: Sound, rhs: Sound) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }
    
}

extension Sound: Identifiable {
    
}

extension Sound: Serializable {
    
    init?(from dict: Dictionary<String, String>) {
        
        guard let id = dict["id"] else {
            return nil
        }
        guard let title = dict["title"] else {
            return nil
        }
        guard let subtitle = dict["subtitle"] else {
            return nil
        }
        guard let description = dict["description"] else {
            return nil
        }
        guard let imageName = dict["imageName"] else {
            return nil
        }
        guard let soundFile = dict["soundFile"] else {
            return nil
        }
        guard let volumeString = dict["volume"], let volume = Float(volumeString) else {
            return nil
        }
        
        self.init(id: id,
              title: title,
              subtitle: subtitle,
              description: description,
              imageName: imageName,
              soundFile: soundFile,
              volume: volume)
    }
    
    func toDictionary() -> Dictionary<String, String> {
        var dict: Dictionary<String, String> = [:]
        
        dict["id"] = id
        dict["title"] = title
        dict["subtitle"] = subtitle
        dict["description"] = description
        dict["imageName"] = imageName
        dict["soundFile"] = soundFile
        dict["volume"] =  String(format: "%f", volume)
     
        return dict
    }
    

    
}
