//
//  RoundedView.swift
//  Noise
//
//  Created by Michael Fröhlich on 15.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class RoundedView: UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat = Injection.theme.cornerRadius {
        didSet {
            layoutSubviews()
        }
    }
    
    func applyTheme() {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        applyTheme()
    }
    
}
