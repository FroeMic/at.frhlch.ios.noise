//
//  SoundToolbarDelegate.swift
//  Noise
//
//  Created by Michael Fröhlich on 08.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

protocol SoundBarDelegate {
    
    func didSelectSoundBar()
    func didPressPause()
    func didPressPlay()
    func didPressNextTrack()
    func didPressPreviousTrack()
    
}
