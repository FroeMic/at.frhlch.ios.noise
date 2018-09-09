//
//  ButtonTableViewCell.swift
//  Noise
//
//  Created by Michael Fröhlich on 09.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {
    
    @IBOutlet var button: PrimaryButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func addTarget(title: String, target: Any?, action: Selector, for: UIControlEvents) {
        button?.setTitle(title, for: .normal)
        button?.addTarget(target, action: action, for: `for`)
    }
    
    
    
}
