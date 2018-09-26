//
//  UDSettingsRepository.swift
//  Noise
//
//  Created by Michael Fröhlich on 24.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

class UDSettingsRepository {
    
    private let userDefaults = UserDefaults.standard
    
    init () {
        if (!userDefaults.bool(forKey: "userDefaultsHaveBeenInitializedKey")) {
            setShowOnboarding(enabled: true)
            setShowInstructionMarks(enabled: true)
            setKeepDisplayActive(enabled: true)
            setAutoPlay(enabled: false)
            setBackgroundPlay(enabled: false)
            setSelectedTab(index: 1)
            userDefaults.set(true, forKey: "userDefaultsHaveBeenInitializedKey")
        }
    }
    private let selectedTabKey = "selectedTabKey"
    private let isOnboardingEnabledKey = "isOnboardingEnabledKey"
    private let isInstructionMarksEnabledKey = "isInstructionMarksEnabledKey"
    private let isKeepDisplayActiveEnabled = "isKeepDisplayActiveEnabled"
    private let isAutoPlayEnabledKey = "isAutoPlayEnabledKey"
    private let isBackgroundPlayEnabledKey = "isBackgroundPlayEnabledKey"

    
}

extension UDSettingsRepository: SettingsRepository {
    
    func setShowOnboarding(enabled: Bool) {
        userDefaults.set(enabled, forKey: isOnboardingEnabledKey)
    }
    
    func getShowOnboarding() -> Bool {
        return userDefaults.bool(forKey: isOnboardingEnabledKey)
    }
    
    func setShowInstructionMarks(enabled: Bool) {
        userDefaults.set(enabled, forKey: isInstructionMarksEnabledKey)
    }
    
    func getShowInstructionMarks() -> Bool {
        return userDefaults.bool(forKey: isInstructionMarksEnabledKey)

    }
    
    func setKeepDisplayActive(enabled: Bool){
        userDefaults.set(enabled, forKey: isKeepDisplayActiveEnabled)
    }
    
    func getKeepDisplayActive() -> Bool {
        return userDefaults.bool(forKey: isKeepDisplayActiveEnabled)
    }
    
    func setSelectedTab(index: Int) {
        userDefaults.set(index, forKey: selectedTabKey)
    }
    
    func getSelectedTab() -> Int{
        return userDefaults.integer(forKey: selectedTabKey)
    }
    
    func setAutoPlay(enabled: Bool) {
        userDefaults.set(enabled, forKey: isAutoPlayEnabledKey)
    }
    
    func getAutoPlay() -> Bool {
        return userDefaults.bool(forKey: isAutoPlayEnabledKey)
    }
    
    func setBackgroundPlay(enabled: Bool) {
        userDefaults.set(enabled, forKey: isBackgroundPlayEnabledKey)
    }
    
    func getBackgroundPlay() -> Bool {
        return userDefaults.bool(forKey: isBackgroundPlayEnabledKey)
    }
        
    
}
