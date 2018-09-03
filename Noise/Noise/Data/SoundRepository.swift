//
//  SoundRepository.swift
//  Noise
//
//  Created by Michael Fröhlich on 02.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

protocol SoundRepository {
    
    func store(_: Sound)
    func get(id: String) -> Sound?
    func getAll() -> [String: Sound]
    func reset()
    
}


