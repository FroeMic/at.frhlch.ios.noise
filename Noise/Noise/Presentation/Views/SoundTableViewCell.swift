//
//  SoundTableViewCell.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class SoundTableViewCell: UITableViewCell {
    

    var delegate: SoundDelegate?
    var sound: Sound? {
        set(sound) {
            self._sound = sound
            updateCellContent()
        }
        get {
            return self._sound
        }
    }
    private var _sound: Sound?
    
    
    @IBOutlet var albumImageView: RoundedImageView!
    @IBOutlet var soundTitleLabel: UILabel!
    @IBOutlet var soundSubtitleLabel: UILabel!
    @IBOutlet var slider: UISlider!
    
    func applyTheme() {
        let theme = Injection.theme
        
        layer.cornerRadius = theme.cornerRadius
        layer.masksToBounds = true
        
        soundTitleLabel.textColor = theme.textColor
        soundSubtitleLabel.textColor = theme.descriptionTextColor
        slider.minimumTrackTintColor =  theme.tintColor
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
        guard let volume = slider?.value else {
            return
        }
        guard let oldSound = sound else {
            return
        }

        _sound = oldSound
        _sound?.volume = volume // set only private sound member to not trigger UI update
        delegate?.soundDidChange(_sound!, oldSound: oldSound)
    }
    
}
