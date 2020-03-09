//
//  ThemeProvider.swift
//  Noise
//
//  Created by Michael Fröhlich on 09.03.20.
//  Copyright © 2020 Michael Fröhlich. All rights reserved.
//

import UIKit

class ThemeProxyProvider: InterfaceTheme {
    
    private var selectedTheme: InterfaceTheme {
        get {
            guard let key = Injection.settingsRepository.getSelectedTheme() else {
                return DefaultTheme()
            }
            if key == DarkTheme.key {
                return DarkTheme()
            }
            if key == DefaultTheme.key {
                return DarkTheme()
            }
            return DefaultTheme()
        }
    }
    
    var tintColor: UIColor {
        return selectedTheme.tintColor
    }
    
    var cornerRadius: CGFloat {
        return selectedTheme.cornerRadius
    }
    
    var textColor: UIColor {
        return selectedTheme.textColor
    }
    
    var backgroundColor: UIColor {
        return selectedTheme.backgroundColor
    }
    
    var descriptionTextColor: UIColor {
        return selectedTheme.descriptionTextColor
    }
    
    var tableViewCellDefaultBackgroundColor: UIColor {
        return selectedTheme.tableViewCellDefaultBackgroundColor
    }
    
    var tableViewCellDefaultTextColor: UIColor {
        return selectedTheme.tableViewCellDefaultTextColor
    }
    
    
    var tableViewCellHighlightBackgroundColor: UIColor {
        return selectedTheme.tableViewCellHighlightBackgroundColor
    }
    
    
    var tableViewCellHighlightTextColor: UIColor {
        return selectedTheme.tableViewCellHighlightTextColor
    }
    
    var barStyle: UIBarStyle {
        return selectedTheme.barStyle
    }
    
    var statusBarStyle: UIStatusBarStyle {
        return selectedTheme.statusBarStyle
    }
}
