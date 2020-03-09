//
//  LicenseTableViewCell.swift
//  ping
//
//  Created by Michael Fröhlich on 05.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class LicenseTableViewCell: UITableViewCell {
    
    var license: License? {
        didSet {
            if let license = license {
                updateCellContent(license)
            }
        }
    }
    
    @IBOutlet var licenseTitleLabel: UILabel!
    @IBOutlet var chevronImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        styleView()
        if let license = license {
            updateCellContent(license)
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        let theme = Injection.theme
        if highlighted {
            contentView.backgroundColor = theme.tintColor
            licenseTitleLabel?.textColor = .white
            licenseTitleLabel?.textColor = .white
            chevronImageView?.tintColor = .white
        } else {
            applyTheme()
        }
        
    }
    
    private func styleView() {
        
        applyTheme()
    }
    
    
    private func applyTheme() {
        let theme = Injection.theme
        
        backgroundColor = theme.backgroundColor
        contentView.backgroundColor = theme.backgroundColor
        
        licenseTitleLabel.textColor = theme.textColor
        
        if let image = chevronImageView.image {
            let coloredImage = image.withRenderingMode(.alwaysTemplate)
            chevronImageView.image = coloredImage
            chevronImageView.tintColor = theme.textColor
        }
        
    }
    
    
    private func updateCellContent(_ license: License) {
        licenseTitleLabel?.text = license.title
    }
    
    public func reloadCellContent() {
        if let license = license {
            updateCellContent(license)
        }
    }
}
