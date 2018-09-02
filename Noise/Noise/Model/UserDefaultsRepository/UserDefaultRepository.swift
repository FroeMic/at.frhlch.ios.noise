//
//  UserDefaultRepository.swift
//  Noise
//
//  Created by Michael Fröhlich on 02.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

class UserDefaultsRepository<T: Serializable & Identifiable>  {
    
    /**
     * The key used to save the values in the suer defaults repository.
     **/
    private let suite: String
    
    /**
     * The user defaults used to store the repository.
     **/
    private let defaults: UserDefaults
    
    init(suite: String) {
        self.suite = suite
        self.defaults = UserDefaults(suiteName: suite)!
    }
    
    private func unarchive(_ archivedObject: Dictionary<String, Any>) -> T? {
        guard let archivedDictionary = archivedObject as? Dictionary<String, String> else {
            return nil
        }
        
        guard let unarchivedObject = T(from: archivedDictionary) else {
            return nil
        }
        
        return unarchivedObject
    }
    
    
    /**
     * Stores/ Updates an object permanently.
     */
    func store(_ object: T) {
        defaults.set(object.toDictionary(), forKey: object.id)
    }
    
    /**
     * Removes an object from the store.
     */
    func remove(id: String) {
        defaults.removeObject(forKey: id)
    }
    
    /**
     * Retrieves a specific object.
     */
    func get(id: String) -> T? {
        guard let archivedObject = defaults.dictionary(forKey: id) else {
            return nil
        }
        return unarchive(archivedObject)
    }
    
    /**
     * Retrieves all objects.
     */
    func getAll() -> [String: T] {
        let keys = defaults.dictionaryRepresentation().keys
        
        var unarchivedObjects: [String: T] = [:]
        for key in keys {
            guard let unarchivedObject = get(id: key) else {
                continue
            }
            unarchivedObjects[key] = unarchivedObject
        }
        return unarchivedObjects
    }
    
    /**
     * Resets the repository to its intial state.
     */
    func reset() {
        let keys = defaults.dictionaryRepresentation().keys
        for key in keys {
            remove(id: key)
        }
    }
    
}


