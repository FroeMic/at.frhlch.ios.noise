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
    @IBOutlet var sliderView: Slider!
    
    private var slider: Slider?
    
    func applyTheme() {
        let theme = Injection.theme
        
        layer.cornerRadius = theme.cornerRadius
        layer.masksToBounds = true
        
        sliderView?.contentViewColor = theme.tintColor
        sliderView.contentViewCornerRadius = theme.cornerRadius
     }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelTextAttributes: [NSAttributedStringKey : Any] = [.font: UIFont.systemFont(ofSize: 10, weight: .bold), .foregroundColor: UIColor.white]

        sliderView.attributedTextForFraction = { fraction in
            let formatter = NumberFormatter()
            formatter.maximumIntegerDigits = 3
            formatter.maximumFractionDigits = 0
            let string = formatter.string(from: (fraction * 100) as NSNumber) ?? ""
            return NSAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: 10, weight: .bold), .foregroundColor: UIColor.black])
        }
        sliderView.setMinimumImage(UIImage(named: "ic_sound_mute"))
        sliderView.setMaximumImage(UIImage(named: "ic_sound_full"))
        sliderView.imagesColor = UIColor.white.withAlphaComponent(0.8)
        sliderView.setMinimumLabelAttributedText(NSAttributedString(string: "", attributes: labelTextAttributes))
        sliderView.setMaximumLabelAttributedText(NSAttributedString(string: "", attributes: labelTextAttributes))
        sliderView.fraction = 1.0
        sliderView.shadowColor = UIColor(white: 0, alpha: 0.1)
        sliderView.valueViewColor = .white
        
        
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
