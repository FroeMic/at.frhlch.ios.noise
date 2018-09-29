//
//  RestorePurchasesTableViewCell.swift
//  Noise
//
//  Created by Michael Fröhlich on 29.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class RestorePurchasesTableViewCell: UITableViewCell {

    @IBOutlet var restorePurchasesLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        restorePurchasesLabel?.text = " Restore Purchases"
        applyTheme()
    }
    
    private func applyTheme() {
        let theme = Injection.theme
        
        restorePurchasesLabel?.textColor = theme.tintColor
    }
}
