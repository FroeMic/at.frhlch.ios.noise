//
//  CircleImageView.swift
//  Noise
//
//  Created by Michael Fröhlich on 29.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        applyBorderRadius()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutSubviews()
        applyBorderRadius()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        applyBorderRadius()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        applyBorderRadius()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyBorderRadius()
    }
    
    private func applyBorderRadius() {
        layer.cornerRadius = bounds.width / 2.0
        layer.masksToBounds = true
    }
}
