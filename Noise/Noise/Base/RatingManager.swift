//
//  RatingManager.swift
//  Noise
//
//  Created by Michael Fröhlich on 24.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation
import Appirater

class RatingManager {
    
    static func triggerRatingView() {
        Appirater.forceShowPrompt(true)
    }
    
    static func setup() {
        Appirater.setAppId("1437191458")
        Appirater.setDaysUntilPrompt(5)
        Appirater.setUsesUntilPrompt(10)
        Appirater.setSignificantEventsUntilPrompt(10)
        Appirater.setTimeBeforeReminding(3)
        Appirater.setDebug(false)
        Appirater.appLaunched(true)
        // Todo: Figure out why this does not work
        Appirater.setCustomAlertMessage("We put a lot of effort into creating Noise. If you like it too, consider rating it on the App Store. Tap a star to rate.")

    }
    
    static func didEnterForeground() {
        Appirater.appEnteredForeground(true)
    }
    
    static func didSignificantEvent() {
        Appirater.userDidSignificantEvent(true)
    }
    
}
