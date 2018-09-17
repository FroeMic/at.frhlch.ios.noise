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
    
    let id: String
    var title: String
    var sounds: [Sound]
    var description: String
    let creationDate: Date
    var lastChangedDate: Date
    
    var creationDateString: String {
        return creationDate.toString(format: .custom("dd MMM hh:mm"))
    }
    var lastChangedDateString: String {
        return lastChangedDate.toString(format: .custom("dd MMM hh:mm"))
    }
    var image: UIImage?
    private var imageData: String? {
        guard let image = image else {
            return nil
        }
        return Mixtape.encodeImage(image)
    }
    
    
    init(id: String,
         title: String,
         sounds: [Sound],
         description: String = "",
         image: UIImage? = nil,
         creationDate: Date = Date(),
         lastChangedDate: Date = Date()) {
        
        self.id = id
        self.title = title
        self.sounds = sounds
        self.description = description
        self.creationDate = creationDate
        self.lastChangedDate = lastChangedDate
        self.image = image
    }
    
    private static func encodeImage(_ image: UIImage) -> String? {
        let pngRepresentation = UIImagePNGRepresentation(image)
        return pngRepresentation?.base64EncodedString(options: .lineLength64Characters)
    }
    
    private static func decodeImageString(_ string: String) -> UIImage? {
        let dataDecoded: Data = Data(base64Encoded: string, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        return decodedimage
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
        guard var soundIDStrings = dict["soundIDs"]?.components(separatedBy: "|") else {
            return nil
        }
        if soundIDStrings.count == 1 && soundIDStrings[0] == "" {
            soundIDStrings = []
        }
        
        guard var soundVolumeStrings = dict["soundVolumes"]?.components(separatedBy: "|") else {
            return nil
        }
        if soundVolumeStrings.count == 1 && soundVolumeStrings[0] == "" {
            soundVolumeStrings = []
        }
        
        guard let dateCreatedString = dict["creationDate"],
            let creationDate = Date(fromString: dateCreatedString, format: .isoDateTimeMilliSec) else {
                return nil
        }
        guard let dateChangedString = dict["lastChangedDate"],
            let lastChangedDate = Date(fromString: dateChangedString, format: .isoDateTimeMilliSec) else {
                return nil
        }
        let description = dict["description"] ?? ""
        var image: UIImage? = nil
        if let imageData = dict["imageData"], imageData.count > 0 {
            image = Mixtape.decodeImageString(imageData)
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
        
        self.init(id: id, title: title, sounds: sounds, description: description, image: image, creationDate: creationDate, lastChangedDate: lastChangedDate)
    }
    
    func toDictionary() -> Dictionary<String, String> {
        var dict: Dictionary<String, String> = [:]
        
        dict["id"] = id
        dict["title"] = title
        dict["creationDate"] = creationDate.toString(format: .isoDateTimeMilliSec)
        dict["lastChangedDate"] = Date().toString(format: .isoDateTimeMilliSec)
        dict["soundIDs"] = sounds.map { $0.id }.joined(separator: "|")
        dict["soundVolumes"] = sounds.map { String(format:"%f", $0.volume) }.joined(separator: "|")
        dict["imageData"] = imageData
        dict["description"] = description
        
        return dict
    }
    
}
