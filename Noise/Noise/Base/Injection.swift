//
//  Injections.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

class Injection {
    
    static private let themeProvider = ThemeProxyProvider()
    static let theme: InterfaceTheme = themeProvider
    static let themePublisher: InterfaceThemeDelegate = themeProvider
    static let feedback: HapticFeedbackManager = HapticFeedbackManager()
    
    static let settingsRepository: SettingsRepository = UDSettingsRepository()
    static let licenseProvider: LicenseProvider = HardCodedLicenseProvider()
    static let soundRepository: SoundRepository = SRSoundRepository()
    static let mixtapeRepository: MixtapeRepository = SRMixtapeRepository()
    
}
