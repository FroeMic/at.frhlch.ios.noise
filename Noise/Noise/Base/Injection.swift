//
//  Injections.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

class Injection {
    
    static let theme: InterfaceTheme = DefaultTheme()
    static let feedback: HapticFeedbackManager = HapticFeedbackManager()
    
    
    static let soundRepository: SoundRepository = UDSoundRepository()
    static let mixtapeRepository: MixtapeRepository = UDMixtapeRepository()
    
    
}
