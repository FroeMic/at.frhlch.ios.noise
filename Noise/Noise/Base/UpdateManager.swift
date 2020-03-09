//
//  UpdateManager.swift
//  Noise
//
//  Created by Michael Fröhlich on 24.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation
import Siren

class UpdateManager {
    
    static func setup() {
        // Siren is a singleton
        let siren = Siren.shared
        
        siren.rulesManager = RulesManager(globalRules: .relaxed)
        siren.presentationManager = PresentationManager.init(alertTintColor: Injection.theme.tintColor,
                                                             alertTitle: "Update Available",
                                                             alertMessage: "A new version of Noise has shipped and can be downloaded from the AppStore. 📦 👈 😊",
                                                             updateButtonTitle: "Update now",
                                                             nextTimeButtonTitle: "Remind me later",
                                                             skipButtonTitle: "Skip this version")
        siren.wail(performCheck: .onDemand, completion: nil)
    }
    
    static func checkVersionRegularly() {
        let siren = Siren.shared
        siren.wail(performCheck: .onForeground, completion: nil)
    }
    
    static func checkVersionImmediately() {
        let siren = Siren.shared
        siren.wail(performCheck: .onDemand, completion: nil)
    }
    
}
