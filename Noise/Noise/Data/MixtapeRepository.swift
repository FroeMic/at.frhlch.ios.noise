//
//  SoundRepository.swift
//  Noise
//
//  Created by Michael Fröhlich on 02.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

protocol MixtapeRepository {
    
    func create(title: String) -> Mixtape? 
    func save(_ mixtape: Mixtape)
    func get(id: String) -> Mixtape?
    func getAll() -> [Mixtape]
    func remove(id: String)
    func reset()
    
}
