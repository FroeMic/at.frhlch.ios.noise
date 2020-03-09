//
//  SettingsTableViewCelkl.swift
//  Noise
//
//  Created by Michael Fröhlich on 09.03.20.
//  Copyright © 2020 Michael Fröhlich. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyTheme()
    }
    
    
    private func applyTheme() {
        styleSubview(view: self)
    }
    
    private func styleSubview(view: UIView) {
        let theme = Injection.theme
        view.backgroundColor = theme.backgroundColor
        for subview in view.subviews {
            if let uiSwitch = subview as? UISwitch {
                // Placing this first is somewhat of a hack ...
                uiSwitch.tintColor = UIColor.lightGray
            } else if subview.subviews.count == 0 {
                subview.backgroundColor = theme.backgroundColor
                
                if let label = subview as? UILabel {
                    label.textColor = theme.textColor
                }
                
            } else {
                styleSubview(view: subview)
            }
        }
    }

}

