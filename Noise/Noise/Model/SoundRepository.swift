//
//  SoundRepository.swift
//  Noise
//
//  Created by Michael Fröhlich on 02.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

protocol SoundRepository {
    
    func create(id: String) -> Sound?
    func save(_: Sound)
    func updateVolume(_: Sound)
    func get(id: String) -> Sound?
    func getAll() -> [Sound]
    func getAll(skipIncomplete: Bool) -> [Sound]
    func remove(id: String)
    func reset()
    
}

