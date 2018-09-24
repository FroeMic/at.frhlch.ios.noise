//
//  SettingsRepository.swift
//  Noise
//
//  Created by Michael Fröhlich on 24.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

protocol SettingsRepository {
    
    func setShowOnboarding(enabled: Bool)
    func getShowOnboarding() -> Bool
    func setSelectedTab(index: Int)
    func getSelectedTab() -> Int
    func setAutoPlay(enabled: Bool)
    func getAutoPlay() -> Bool
    func setBackgroundPlay(enabled: Bool)
    func getBackgroundPlay() -> Bool
    
}
