//
//  ThemeDelegate.swift
//  Noise
//
//  Created by Michael Fröhlich on 09.03.20.
//  Copyright © 2020 Michael Fröhlich. All rights reserved.
//

import Foundation

protocol InterfaceThemeDelegate {
    
    func subscribeToThemeUpdates(_ subscriber: InterfaceThemeSubscriber)
    func notifySubscribers()
}
