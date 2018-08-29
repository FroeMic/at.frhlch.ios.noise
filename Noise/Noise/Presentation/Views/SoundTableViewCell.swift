//
//  SoundTableViewCell.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit
import fluid_slider

class SoundTableViewCell: UITableViewCell {
    
    var sound: Sound? {
        didSet {
            updateCellContent()
        }
    }
    
    @IBOutlet var albumImageView: RoundedImageView!
    @IBOutlet var soundTitleLabel: UILabel!
    @IBOutlet var sliderContainerView: UIView!
    
    private var slider: Slider?
    
    func applyTheme() {
        let theme = Injection.theme
        
        layer.cornerRadius = theme.cornerRadius
        layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if slider == nil {

        }
        
        applyTheme()
    }
    
    func updateCellContent() {
        guard let sound = sound else {
            return
        }
        
        albumImageView?.image = sound.image
        soundTitleLabel?.text = sound.title
        
    }
    
}
