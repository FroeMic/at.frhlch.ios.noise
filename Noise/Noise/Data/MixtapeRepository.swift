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
    func store(_ object: Mixtape)
    func get(id: String) -> Mixtape?
    func getAll() -> [String: Mixtape]
    func reset()
    
}
