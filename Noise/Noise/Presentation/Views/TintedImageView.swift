//
//  File.swift
//  Noise
//
//  Created by Michael Fröhlich on 26.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class TintedImageView: UIImageView {
    
    private var firstLayout: Bool = true
    
    override var image: UIImage? {
        get {
            return super.image
        }
        set (newImage) {
            super.image = newImage?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if firstLayout {
            image = super.image
            firstLayout = false
        }
        
        tintColor = Injection.theme.tintColor
    }
    
}
