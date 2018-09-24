//
//  MixtapeTableViewCell.swift
//  Noise
//
//  Created by Michael Fröhlich on 15.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class MixtapeTableViewCell: UITableViewCell {
    
    var mixtape: Mixtape? {
        set(mixtape) {
            self._mixtape = mixtape
            updateCellContent()
        }
        get {
            return self._mixtape
        }
    }
    private var _mixtape: Mixtape?

    @IBOutlet var mixtapeTitleLabel: UILabel!
    @IBOutlet var mixtapeNrOfSongsLabel: UILabel!
    @IBOutlet var mixtapeSubtitleLabel: UILabel!
    @IBOutlet var coverImageView: RoundedImageView!

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        applyTheme()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        let theme = Injection.theme
        
        if highlighted {
            contentView.backgroundColor = theme.tableViewCellHighlightBackgroundColor
            mixtapeTitleLabel?.textColor = theme.tableViewCellHighlightTextColor
            mixtapeNrOfSongsLabel?.textColor = theme.tableViewCellHighlightTextColor
            mixtapeSubtitleLabel?.textColor = theme.tableViewCellHighlightTextColor
        } else {
            applyTheme()
        }
    }
    
    func applyTheme() {
        let theme = Injection.theme
        
        contentView.backgroundColor = theme.tableViewCellDefaultBackgroundColor
        mixtapeTitleLabel?.textColor = theme.textColor
        mixtapeNrOfSongsLabel?.textColor = theme.descriptionTextColor
        mixtapeSubtitleLabel?.textColor = theme.descriptionTextColor
    }
    
    func updateCellContent() {
        guard let mixtape = mixtape else {
            return
        }
        
        
        mixtapeTitleLabel?.text = mixtape.title
        mixtapeNrOfSongsLabel?.text = String(format: "%d  sounds", mixtape.sounds.count)
        mixtapeSubtitleLabel?.text = mixtape.detailDescription
        coverImageView.image = mixtape.image
    }
    
 
}
