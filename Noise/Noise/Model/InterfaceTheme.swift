//
//  Theme.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

protocol InterfaceTheme {
    
    var tintColor: UIColor { get }
    var cornerRadius: CGFloat { get }
    var textColor: UIColor { get }
    var backgroundColor: UIColor { get }
    var descriptionTextColor: UIColor { get }
    
    var tableViewCellDefaultBackgroundColor: UIColor { get }
    var tableViewCellDefaultTextColor: UIColor { get }
    var tableViewCellHighlightBackgroundColor: UIColor { get }
    var tableViewCellHighlightTextColor: UIColor { get }
    
    var barStyle: UIBarStyle { get }
    var statusBarStyle: UIStatusBarStyle { get }
    
}
