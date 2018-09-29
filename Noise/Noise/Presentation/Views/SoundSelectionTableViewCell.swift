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
    
    @IBOutlet var albumImageView: RoundedImageView!
    @IBOutlet var selectedView: UIImageView!
    @IBOutlet var soundTitleLabel: UILabel!
    @IBOutlet var soundSubtitleLabel: UILabel!
    @IBOutlet var purchaseIconView: CircleImageView!
    @IBOutlet var overlayView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        _selectedImage = _selectedImage.withRenderingMode(.alwaysTemplate)
        _deselectedImage = _deselectedImage.withRenderingMode(.alwaysTemplate)
        
        setSelectedImage()
        applyTheme()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        let theme = Injection.theme

        if highlighted {
            contentView.backgroundColor = theme.tableViewCellHighlightBackgroundColor
            soundTitleLabel?.textColor = theme.tableViewCellHighlightTextColor
            soundSubtitleLabel?.textColor = theme.tableViewCellHighlightTextColor
            selectedView?.tintColor = theme.tableViewCellHighlightTextColor
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
        
        contentView.backgroundColor = theme.tableViewCellDefaultBackgroundColor
        soundTitleLabel?.textColor = theme.textColor
        soundSubtitleLabel?.textColor = theme.descriptionTextColor
        selectedView?.tintColor = theme.tintColor
        
        if let purchaseIconView = purchaseIconView {
            purchaseIconView.tintColor = theme.tintColor
            purchaseIconView.image = purchaseIconView.image?.withRenderingMode(.alwaysTemplate)
            purchaseIconView.backgroundColor = .white
        }
        
        applyPremiumFilter()
    }
    
    func applyPremiumFilter() {
        guard let sound = sound else {
            return
        }
        if sound.isOwned {
            albumImageView?.image = sound.image
            overlayView?.isHidden = true
            purchaseIconView?.isHidden = true
        } else {
            albumImageView?.image = sound.image?.mono
            overlayView?.isHidden = false
            purchaseIconView?.isHidden = false
        }
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
