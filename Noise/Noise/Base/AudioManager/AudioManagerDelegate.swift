//
//  AudioManagerDelegate.swift
//  Noise
//
//  Created by Michael Fröhlich on 07.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

protocol AudioManagerDelegate: class {
    
    func audioManager(_ audioManager: AudioManager, didChange state: AudioManagerState)
    func audioManager(_ audioManager: AudioManager, didPressNextTrack: Bool)
    func audioManager(_ audioManager: AudioManager, didPressPrevTrack: Bool)
}

extension AudioManagerDelegate {
    func audioManager(_ audioManager: AudioManager, didPressNextTrack: Bool) {
        
    }
    func audioManager(_ audioManager: AudioManager, didPressPrevTrack: Bool){
        
    }
}
