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

    func applyTheme() {
        let theme = Injection.theme

        mixtapeTitleLabel.textColor = theme.textColor
        mixtapeNrOfSongsLabel.textColor = theme.descriptionTextColor
        mixtapeSubtitleLabel.textColor = theme.descriptionTextColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        applyTheme()
    }
    
    func updateCellContent() {
        guard let mixtape = mixtape else {
            return
        }
        
        mixtapeTitleLabel?.text = mixtape.title
        mixtapeNrOfSongsLabel?.text = String(format: "%d  sounds", mixtape.sounds.count)
        mixtapeSubtitleLabel?.text = mixtape.description
    
    }
    
 
}
