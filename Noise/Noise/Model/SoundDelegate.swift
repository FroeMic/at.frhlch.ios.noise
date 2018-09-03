//
//  SoundDelegate.swift
//  Noise
//
//  Created by Michael Fröhlich on 03.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

protocol SoundDelegate {
    
    func soundDidChange(_ sound: Sound, oldSound: Sound)
    
}
