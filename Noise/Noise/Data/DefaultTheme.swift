//
//  DefaultTheme.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class DefaultTheme: InterfaceTheme {
    
    // let tintColor: UIColor = UIColor(displayP3Red: 255/255, green: 45/255, blue: 85/255, alpha: 1.0)
    let tintColor: UIColor = UIColor(red:0.26, green:0.80, blue:0.79, alpha:1.00)
    let cornerRadius: CGFloat = 4.0
    let textColor: UIColor = .black
    let descriptionTextColor: UIColor = .gray
    
    var tableViewCellDefaultBackgroundColor: UIColor = .white
    var tableViewCellDefaultTextColor: UIColor = .black
    var tableViewCellHighlightBackgroundColor: UIColor = UIColor(red:0.26, green:0.80, blue:0.79, alpha:1.00)
    var tableViewCellHighlightTextColor: UIColor = .white
}
