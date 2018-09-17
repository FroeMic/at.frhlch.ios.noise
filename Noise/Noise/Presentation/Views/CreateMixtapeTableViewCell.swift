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
        
        // Todo: Add proper image
        //customImageView.image = UIImage(named: "")
        customLabel.textColor = Injection.theme.tintColor
    }
    
}
