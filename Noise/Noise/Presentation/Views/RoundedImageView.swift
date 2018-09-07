//
//  RoundedImageView\.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {
    
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
