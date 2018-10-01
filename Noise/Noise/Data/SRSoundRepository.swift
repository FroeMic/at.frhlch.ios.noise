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
        self.save(sound, inBackground: false)
    }
    
    func save(_ sound: Sound, inBackground: Bool) {
        // otherwise we will run into a deadlock
        
        if inBackground {
            DispatchQueue(label: "bg").async {
                self.saveSound(sound: sound, in: self.db.saveContext)
            }
        } else {
            saveSound(sound: sound)
        }
    }
    
    private func saveSound(sound: Sound, in context: Context? = nil ) {
        do {
            try db.operation { ( defaultContext, save) throws in
                guard let managedSound = self.get(sound: sound, context: context ?? defaultContext) else {
                    return
                }
                
                managedSound.update(sound: sound)
                save()
            }
        } catch {
            // There was an error in the operation
        }
    }
    
    func updateVolume(_ sound: Sound) {
        do {
            try db.operation { (context, save) throws in
                
                guard let managedSound = self.get(sound: sound, context: context) else {
                    return
                }
                
                managedSound.volume = sound.volume
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
        return getAll(skipIncomplete: true)
    }
    
    func getAll(skipIncomplete: Bool) -> [Sound] {
        let fetchRequest: FetchRequest<ManagedSound>
        if skipIncomplete {
            fetchRequest = FetchRequest<ManagedSound>()
                .filtered(with: NSPredicate(format: "filesDownloaded == %@", NSNumber(value: true)))
                .sorted(with: NSSortDescriptor(key: "category", ascending: true))
        } else {
            fetchRequest = FetchRequest<ManagedSound>()
        }
        
        guard let managedSounds = try? db.fetch(fetchRequest) else {
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
            managedSound.contentDownloaded = dict["contentDownloaded"] == "true"
            managedSound.filesDownloaded = dict["filesDownloaded"] == "true"
            managedSound.needsUpdate = dict["needsUpdate"] == "true"
            managedSound.inAppPurchaseId = dict["inAppPurchaseId"]
            managedSound.priceString = dict["priceString"]
            managedSound.category = dict["category"]
            managedSound.volume = Float(dict["volume"] ?? "0") ?? 0
            
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
        self.inAppPurchaseId = sound.inAppPurchaseId
        self.contentDownloaded = sound.contentDownloaded
        self.filesDownloaded = sound.filesDownloaded
        self.needsUpdate = sound.needsUpdate
        self.priceString = sound.priceString
        self.category = sound.category
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
                "imageFilePath": "001-autumn-rain.jpg",
                "soundFilePath": "001-autumn-rain.mp3",
                "contentDownloaded": "true",
                "filesDownloaded": "true",
                "needsUpdate": "false",
                "category": "c002-nature"
            ],
            [
                "id": "002-berlin-coffee-shop",
                "title": "Coffee Shop",
                "subtitle": "Find yourself in a coffee shop buzzing with life",
                "detailDescription": "Dive into the scenery of a Berlin coffee shop buzzing with energy. The pleasant smell of freshly brewed coffee hangs in the air while the busy chatter of people all around you blends in with the venue. Time to get to work.",
                "imageFilePath": "002-berlin-coffee-shop.jpg",
                "soundFilePath": "002-berlin-coffee-shop.mp3",
                "contentDownloaded": "true",
                "filesDownloaded": "true",
                "needsUpdate": "false",
                "category": "c001-people",
                "volume": "0.3"
            ],
            [
                "id": "031-public-pool",
                "title": "Swimming Pool",
                "subtitle": "Relax along the swimming pool area of a hotel",
                "detailDescription": "Lay down near the swimming pool of a busy hotel. The evening sun illuminates the scenery and warms your body as you listen to the lively chatter of hotel guests and joyful screams of children playing in the water.",
                "imageFilePath": "031-public-pool.jpg",
                "soundFilePath": "031-public-pool.mp3",
                "contentDownloaded": "true",
                "filesDownloaded": "true",
                "needsUpdate": "false",
                "category": "c001-people"
            ],
            [
                "id": "033-seaside-waves",
                "title": "Seaside Waves",
                "subtitle": "Walk along an isolated mediterranean beach",
                "detailDescription": "Take off you shoes and stroll along an isolated mediterranean beach. Listen to the ever-changing sound of the waves breaking the shore.",
                "imageFilePath": "033-seaside-waves.jpg",
                "soundFilePath": "033-seaside-waves.mp3",
                "contentDownloaded": "true",
                "filesDownloaded": "true",
                "needsUpdate": "false",
                "category": "c002-nature"
            ],
            [
                "id": "006-moderate-wind",
                "title": "Refreshing Spring Wind",
                "subtitle": "Medium-strength wind blowing on a windy spring day",
                "detailDescription": "Open your window and let this moderate spring wind bring in some fresh air. As the cold air touches you skin you immediately feel awake and alive.",
                "imageFilePath": "006-moderate-wind.jpg",
                "soundFilePath": "006-moderate-wind.mp3",
                "contentDownloaded": "true",
                "filesDownloaded": "true",
                "needsUpdate": "false",
                "category": "c002-nature"
            ],
            [
                "id": "012-small-river",
                "title": "Small River",
                "subtitle": "A shallow stream making its way around some rocks",
                "detailDescription": "Take a pause and enjoy the relaxing sound of this small river running through the grass. Picture the cold water in its relentless struggle to find a way around the rocks in its way.",
                "imageFilePath": "012-small-river.jpg",
                "soundFilePath": "012-small-river.mp3",
                "contentDownloaded": "true",
                "filesDownloaded": "true",
                "needsUpdate": "false",
                "category": "c002-nature"
            ],
            [
                "id": "014-relaxing-shower",
                "title": "Relaxing Shower",
                "subtitle": "The relaxing sound of a pleasant shower",
                "detailDescription": "Take a relaxing shower and forget the world around you for a moment. As the soft drops of water touch your skin, it seems as if the stress of the day is washed away. Your body starts to relax and your mind starts wandering.",
                "imageFilePath": "014-relaxing-shower.jpg",
                "soundFilePath": "014-relaxing-shower.mp3",
                "contentDownloaded": "true",
                "filesDownloaded": "true",
                "needsUpdate": "false",
                "category": "c005-urban"
            ],
            [
                "id": "016-city-ambience",
                "title": "City Atmosphere",
                "subtitle": "The acoustic fingerprint of a city at night",
                "detailDescription": "Close your eyes and breath in the acoustic fingerprint of this city at night. Occasional traffic is mixed with the never-silent background noise of a place that never truly sleeps.",
                "imageFilePath": "016-city-ambience.jpg",
                "soundFilePath": "016-city-ambience.mp3",
                "contentDownloaded": "true",
                "filesDownloaded": "true",
                "needsUpdate": "false",
                "category": "c005-urban"
            ],
            [
                "id": "004-small-wood-fire",
                "title": "Small Camp Fire",
                "subtitle": "A gentle wood fire burning on hay and branches",
                "detailDescription": "Sit down next to this petite wood fire and listen to the ever changing cracking of the branches as they are devoured by the heat of the flames. Perfect for cold autumn days.",
                "imageFilePath": "004-small-wood-fire.jpg",
                "soundFilePath": "004-small-wood-fire.mp3",
                "contentDownloaded": "true",
                "filesDownloaded": "true",
                "needsUpdate": "false",
                "category": "c002-nature"
            ],
            [
                "id": "019-rocky-mountains",
                "title": "Rocky Mountains",
                "subtitle": "Pine trees bending in the wind and birds chriping",
                "detailDescription": "Slow down for a moment and appreciate the nature of the Rocky Mountains around you. You can hear gentle wind blowing through the pine trees and birds chirping away.",
                "imageFilePath": "019-rocky-mountains.jpg",
                "soundFilePath": "019-rocky-mountains.mp3",
                "contentDownloaded": "true",
                "filesDownloaded": "true",
                "needsUpdate": "false",
                "category": "c002-nature"
            ],
            [
                "id": "005-wind-chimes",
                "title": "Wind Chimes",
                "subtitle": "The bright tinkling sound of wind chimes",
                "detailDescription": "Listen to the bright sound of wind chimes hanging on a nearby tree.",
                "imageFilePath": "005-wind-chimes.jpg",
                "soundFilePath": "005-wind-chimes.mp3",
                "contentDownloaded": "true",
                "filesDownloaded": "true",
                "needsUpdate": "false",
                "category": "c002-nature"
            ],
            [
                "id": "003-light-forest-rain",
                "title": "Storm and Thunder",
                "subtitle": "Wind, rain and distant thunder from an Austrian forest",
                "detailDescription": "Distant thunder can be heard while thousand of small drops find their way through the trees of the forest to the ground.",
                "imageFilePath": "003-light-forest-rain.jpg",
                "soundFilePath": "003-light-forest-rain.mp3",
                "contentDownloaded": "true",
                "filesDownloaded": "true",
                "needsUpdate": "false",
                "category": "c002-nature"
            ]
        ]
    }
}
