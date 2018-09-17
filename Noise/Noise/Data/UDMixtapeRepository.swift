//
//  File.swift
//  Noise
//
//  Created by Michael Fröhlich on 03.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

class UDMixtapeRepository: UserDefaultsRepository<Mixtape>, MixtapeRepository {
    
    init() {
        super.init(suite: "at.frhlch.ios.noise.mixtapes")
    }
    
    private func getNextId() -> String? {
        let mixtapes = getAll()
        
        if mixtapes.count == 0 {
            return "0"
        }
        
        if let maxKey = mixtapes.keys.max(), let intKey = Int(maxKey) {
            return "\(intKey+1)"
        }
        
        return nil
    }
    
    func create(title: String) -> Mixtape? {
        
        guard let id = getNextId() else {
            return nil
        }
        
        let mixtape = Mixtape(id: id, title: title, sounds: [])
        store(mixtape)
            
        debugPrint(getAll())
        
        return mixtape
    }
    
}
