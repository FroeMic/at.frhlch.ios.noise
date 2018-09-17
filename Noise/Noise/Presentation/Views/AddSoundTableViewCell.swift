//
//  AddSoundTableViewCell.swift
//  Noise
//
//  Created by Michael Fröhlich on 17.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class AddSoundTableViewCell: UITableViewCell {
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var customLabel: UILabel!
    
    func applyTheme() {
        let theme = Injection.theme
        
        customLabel?.textColor = theme.tintColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyTheme()
    }

}
