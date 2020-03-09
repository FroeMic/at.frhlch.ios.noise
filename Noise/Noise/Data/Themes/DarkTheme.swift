//
//  DefaultTheme.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class DarkTheme: InterfaceTheme {
    
    static let key = "DarkThemeKey"
    
    // let tintColor: UIColor = UIColor(displayP3Red: 255/255, green: 45/255, blue: 85/255, alpha: 1.0)
    let tintColor: UIColor = UIColor(red:0.26, green:0.80, blue:0.79, alpha:1.00)
    let cornerRadius: CGFloat = 4.0
    let textColor: UIColor = .white
    var backgroundColor: UIColor = .black
    let descriptionTextColor: UIColor = .gray
    
    var tableViewCellDefaultBackgroundColor: UIColor = .black
    var tableViewCellDefaultTextColor: UIColor = .white
    var tableViewCellHighlightBackgroundColor: UIColor = UIColor(red:0.26, green:0.80, blue:0.79, alpha:1.00)
    var tableViewCellHighlightTextColor: UIColor = .black
    
    var barStyle: UIBarStyle = .black
    var statusBarStyle: UIStatusBarStyle = .lightContent

}
