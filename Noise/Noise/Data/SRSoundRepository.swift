//
//  SRSoundRepository.swift
//  Noise
//
//  Created by Michael Fröhlich on 20.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation
import SugarRecord

class SRSoundRepository {
    
    private let db: CoreDataDefaultStorage
    
    init() {
        db = SRSoundRepository.coreDataStorage()
        
        if getAll().count == 0 {
            reset()
        }
    }
    
    // Initializing CoreDataDefaultStorage
    private static func coreDataStorage() -> CoreDataDefaultStorage {
        let store = CoreDataStore.named("db")
        let bundle = Bundle.main
        let model = CoreDataObjectModel.merged([bundle])
        let defaultStorage = try! CoreDataDefaultStorage(store: store, model: model)
        return defaultStorage
    }
    
    private func get(sound: Sound, context: Context) -> ManagedSound? {
        do {
            return try context.fetch(FetchRequest<ManagedSound>().filtered(with: "id", equalTo: sound.id)).first
        } catch {
            return nil
        }
    }
    
    private func new(id: String) -> ManagedSound? {
        if let _ = get(id: id) {
            return nil
        }
        
        do {
            return try db.operation { (context, save) throws -> ManagedSound? in
                let managedSound: ManagedSound = try context.new()
                managedSound.id = id
                managedSound.title = ""
                managedSound.subtitle = ""
                managedSound.detailedDescription = ""
                
                try context.insert(managedSound)
                save()
                return managedSound
            }
        } catch {
            return nil
        }
    }
}


extension SRSoundRepository: SoundRepository {
    func create(id: String) -> Sound? {
        guard let managedSound = new(id: id) else {
            return nil
        }
        return Sound(managedSound: managedSound)
    }
    
    func save(_ sound: Sound) {
        do {
            try db.operation { (context, save) throws in
                
                guard let managedSound = self.get(sound: sound, context: context) else {
                    return
                }
                
                managedSound.update(sound: sound)
                save()
            }
        } catch {
            // There was an error in the operation
        }
    }
    
    func get(id: String) -> Sound? {
        let fetchResult: ManagedSound?? = try? db.fetch(FetchRequest<ManagedSound>().filtered(with: "id", equalTo: id)).first
        guard let noErrorResult = fetchResult else {
            return nil
        }
        guard let managedSound = noErrorResult else {
            return nil
        }
        return Sound(managedSound: managedSound)
    }
    
    func getAll() -> [Sound] {
        guard let managedSounds = try? db.fetch(FetchRequest<ManagedSound>()) else {
            return []
        }
        
        return managedSounds.compactMap { Sound(managedSound: $0) }
    }
    
    func remove(id: String) {
        do {
            try db.operation { (context, save) throws in
                let fetchResult: ManagedSound? = try context.request(ManagedSound.self).filtered(with: "id", equalTo: id).fetch().first
                if let managedSound = fetchResult {
                    try context.remove([managedSound])
                    save()
                }
            }
        } catch {
            // There was an error in the operation
        }
    }
    
    
    func reset() {
        // remove all
        do {
            try db.operation { (context, save) throws in
                let sounds: [ManagedSound] = try context.request(ManagedSound.self).fetch()
                try context.remove(sounds)
                save()
            }
        } catch {
            // There was an error in the operation
        }

        for dict in seedValues {
            guard let id = dict["id"] else {
                continue
            }
            guard let managedSound = new(id: id) else {
                continue
            }

            managedSound.title = dict["title"]
            managedSound.subtitle = dict["subtitle"]
            managedSound.detailedDescription = dict["detailDescription"]
            managedSound.imageFilePath = dict["imageFilePath"]
            managedSound.soundFilePath = dict["soundFilePath"]
            managedSound.remoteUrl = dict["remoteUrl"]
            managedSound.inAppPurchaseId = dict["inAppPurchaseId"]

            if let sound = Sound(managedSound: managedSound) {
                save(sound)
            }
        }
    }
    
    
}

extension ManagedSound {
    
    func update(sound: Sound) {
        guard let id = self.id, id == sound.id else {
            return
        }
        
        self.title = sound.title
        self.subtitle = sound.subtitle
        self.detailedDescription = sound.detailDescription
        
        if sound.volume > 1 {
            self.volume = 1.0
        } else if sound.volume < 0 {
            self.volume = 0.0
        } else {
            self.volume = sound.volume
        }

        self.imageFilePath = sound.imageFilePath
        self.soundFilePath = sound.soundFilePath
        self.remoteUrl = sound.remoteUrl
    }
    
}

extension SRSoundRepository {
    
    var seedValues: [[String:String]] {
        return [
            [
                "id": "001-autumn-rain",
                "title": "Autumn Rain",
                "subtitle": "Thick drops of rain dumming to the ground",
                "detailDescription": "Calm your mood with the sound of autumn rainfall. Hundreds of thick and heavy drops drum to the ground creating a soothing sound atmosphere.",
                "imageFilePath": "sound_heavy_rain.jpg",
                "soundFilePath": "audio_rain_60s.mp3",
            ],
            [
                "id": "002-berlin-coffee-shop",
                "title": "Berlin Coffee  Shop",
                "subtitle": "Find yourself in a Berlin coffee shop buzzing with life",
                "detailDescription": "Dive into the scenery of a Berlin coffee shop buzzing with energy. The pleasant smell of freshly brewed coffee hangs in the air while the busy chatter of people all around you blends in with the venue. Time to get to work",
                "imageFilePath": "sound_coffee_shop.jpg",
                "soundFilePath": "audio_cafe_60s.mp3",
            ]
        ]
    }
}
