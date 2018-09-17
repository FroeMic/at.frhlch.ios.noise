//
//  SoundSelectionTableViewCell.swift
//  Noise
//
//  Created by Michael Fröhlich on 17.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class SoundSelectionTableViewCell: UITableViewCell {
    
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
    private var _selectedImage = UIImage(named: "ic_sound_selected")!
    private var _deselectedImage = UIImage(named: "ic_sound_not_selected")!
    private var _highlightBackgroundColor: UIColor = .lightGray
    private var _highlightTextColor: UIColor = .black
    
    @IBOutlet var albumImageView: RoundedImageView!
    @IBOutlet var selectedView: UIImageView!
    @IBOutlet var soundTitleLabel: UILabel!
    @IBOutlet var soundSubtitleLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setSelectedImage()
        applyTheme()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            contentView.backgroundColor = _highlightBackgroundColor
            soundTitleLabel?.textColor = _highlightTextColor
            soundSubtitleLabel?.textColor = _highlightTextColor
            selectedView?.tintColor = .white
        } else {
            applyTheme()
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setSelectedImage()
    }
    
    func applyTheme() {
        let theme = Injection.theme
        
        contentView.backgroundColor = .white
        soundTitleLabel?.textColor = theme.textColor
        soundSubtitleLabel?.textColor = theme.descriptionTextColor
        selectedView?.tintColor = theme.tintColor
        
        _selectedImage = _selectedImage.withRenderingMode(.alwaysTemplate)
        _deselectedImage = _deselectedImage.withRenderingMode(.alwaysTemplate)
        
        _highlightBackgroundColor = theme.tintColor
        _highlightTextColor =  .white
    }
    
    private func setSelectedImage() {
        if isSelected {
            selectedView.image = _selectedImage
        } else {
            selectedView.image = _deselectedImage
        }
    }
    
    func updateCellContent() {
        guard let sound = sound else {
            return
        }
        
        albumImageView?.image = sound.image
        soundTitleLabel?.text = sound.title
        soundSubtitleLabel?.text = sound.subtitle
    }
    
}
