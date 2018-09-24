//
//  SRMixtapeRepository.swift
//  Noise
//
//  Created by Michael Fröhlich on 20.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation
import SugarRecord

class SRMixtapeRepository {
    
    private let db: CoreDataDefaultStorage
    
    init() {
        db = SRMixtapeRepository.coreDataStorage()
        
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
    
    private func get(mixtape: Mixtape, context: Context) -> ManagedMixtape? {
        do {
            return try context.fetch(FetchRequest<ManagedMixtape>().filtered(with: "uuid", equalTo: mixtape.id)).first
        } catch {
            return nil
        }
    }
    
private func new(title: String, context: Context) -> ManagedMixtape? {
        do {
            let managedMixtape: ManagedMixtape = try context.new()
            managedMixtape.uuid = UUID().uuidString
            managedMixtape.title = title
            return managedMixtape
        } catch {
            return nil
        }
    }
    
}


extension SRMixtapeRepository: MixtapeRepository {
    func create(title: String) -> Mixtape? {
        do {
            return try db.operation { (context, save) throws -> Mixtape? in
                guard let managedMixtape = self.new(title: title, context: context) else {
                    return nil
                }
                
                try context.insert(managedMixtape)
                save()
                
                return Mixtape(managedMixtape: managedMixtape)
            }
        } catch {
            return nil
        }
    }
    
    func save(_ mixtape: Mixtape) {
        do {
            try db.operation { (context, save) throws in
                guard let managedMixtape = self.get(mixtape: mixtape, context: context) else {
                    return
                }
                
                managedMixtape.update(mixtape: mixtape, context: context)
                save()
            }
        } catch {
            // There was an error in the operation
        }
    }
    
    func get(id: String) -> Mixtape? {
        let fetchResult: ManagedMixtape?? = try? db.fetch(FetchRequest<ManagedMixtape>().filtered(with: "uuid", equalTo: id)).first
        guard let noErrorResult = fetchResult else {
            return nil
        }
        guard let managedMixtape = noErrorResult else {
            return nil
        }
        return Mixtape(managedMixtape: managedMixtape)
    }
    
    func getAll() -> [Mixtape] {
        guard let managedMixtapes = try? db.fetch(FetchRequest<ManagedMixtape>()) else {
            return []
        }
        
        return managedMixtapes.compactMap { Mixtape(managedMixtape: $0) }
    }
    
    func remove(id: String) {
        do {
            try db.operation { (context, save) throws in
                let fetchResult: ManagedMixtape? = try context.request(ManagedMixtape.self).filtered(with: "uuid", equalTo: id).fetch().first
                if let managedMixtape = fetchResult {
                    try context.remove([managedMixtape])
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
                let mixtapes: [ManagedMixtape] = try context.request(ManagedMixtape.self).fetch()
                try context.remove(mixtapes)
                save()
            }
        } catch {
            // There was an error in the operation
        }
    }

}

extension ManagedMixtape {
    
    func update(mixtape: Mixtape, context: Context) {
        guard let id = self.uuid, id == mixtape.id else {
            return
        }
        
        self.title = mixtape.title
        self.detailDescription = mixtape.detailDescription
        self.imageFilePath = mixtape.imageFilePath
        
        for obj in self.sounds ?? NSSet() {
            if let managedMixtapeSound = obj as? ManagedMixtapeSound {
                removeMixtapeSound(mixtapeSound: managedMixtapeSound, context: context)
            }
            
        }
        
        var mixtapeSounds: [ManagedMixtapeSound] = []
        for sound in mixtape.sounds {
            if let managedMixtapeSound = newMixtapeSound(sound: sound, context: context) {
                mixtapeSounds.append(managedMixtapeSound)
            }
        }
        self.sounds = NSSet(array: mixtapeSounds)
    }

    private func newMixtapeSound(sound: Sound, context: Context) -> ManagedMixtapeSound? {
        guard let managedSound = getSound(sound: sound, context: context) else {
            return nil
        }
        
        do {
            let managedMixtapeSound: ManagedMixtapeSound = try context.new()
            managedMixtapeSound.soundID = sound.id
            managedMixtapeSound.volume = sound.volume
            managedMixtapeSound.sound = managedSound
            return managedMixtapeSound
        } catch {
            return nil
        }
    }
    
    private func getSound(sound: Sound, context: Context) -> ManagedSound? {
        do {
            let managedSound: ManagedSound? = try context.fetch(FetchRequest<ManagedSound>().filtered(with: "id", equalTo: sound.id)).first
            return managedSound
        } catch {
            return nil
        }
    }
    
    private func removeMixtapeSound(mixtapeSound: ManagedMixtapeSound, context: Context) {
        do {
            try context.remove([mixtapeSound])
        } catch {
            // There was an error in the operation
        }
    }
}

