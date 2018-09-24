//
//  CreateMixtapeTableViewCell.swift
//  Noise
//
//  Created by Michael Fröhlich on 09.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class CreateMixtapeTableViewCell: UITableViewCell {
    
    @IBOutlet var customImageView: RoundedImageView!
    @IBOutlet var customLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        applyTheme()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        let theme = Injection.theme
        
        if highlighted {
            contentView.backgroundColor = theme.tableViewCellHighlightBackgroundColor
            customLabel?.textColor = theme.tableViewCellHighlightTextColor
        } else {
            applyTheme()
        }
    }
    
    func applyTheme() {
        let theme = Injection.theme
        
        contentView.backgroundColor = theme.tableViewCellDefaultBackgroundColor
        customLabel?.textColor = theme.tintColor
    }
    
    
}
