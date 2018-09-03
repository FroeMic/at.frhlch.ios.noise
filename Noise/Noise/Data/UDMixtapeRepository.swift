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
}
