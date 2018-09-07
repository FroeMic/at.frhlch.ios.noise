//
//  PrimaryButton.swift
//  Noise
//
//  Created by Michael Fröhlich on 07.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class PrimaryButton: UIButton {
    
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
