//
//  SoundTableViewCell.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class SoundTableViewCell: UITableViewCell {
    
    var sound: Sound? {
        didSet {
            updateCellContent()
        }
    }
    
    @IBOutlet var albumImageView: RoundedImageView!
    @IBOutlet var soundTitleLabel: UILabel!
    @IBOutlet var soundSubtitleLabel: UILabel!
    @IBOutlet var slider: UISlider!
    
    func applyTheme() {
        let theme = Injection.theme
        
        layer.cornerRadius = theme.cornerRadius
        layer.masksToBounds = true
        
     }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let sliderThumbImage = UIImage(named: "slider_thumb"){
            slider?.setThumbImage(sliderThumbImage, for: .normal)
            slider?.minimumValue = 0.0
            slider?.maximumValue = 1.0
            
            slider.addTarget(self, action: #selector(SoundTableViewCell.sliderValueDidChange), for: .valueChanged)
        }
        
        
        applyTheme()
    }
    
    func updateCellContent() {
        guard let sound = sound else {
            return
        }
        
        albumImageView?.image = sound.image
        soundTitleLabel?.text = sound.title
        soundSubtitleLabel?.text = sound.subtitle
        slider?.value = sound.volume
        
    }
    
    @objc func sliderValueDidChange() {

    }
    
}
