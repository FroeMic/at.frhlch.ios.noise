//
//  InAppPurchaseCell.swift
//  Noise
//
//  Created by Michael Fröhlich on 29.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class InAppPurchaseTableViewCell: UITableViewCell {
    
    var inAppPurchase: InAppPurchase? {
        didSet {
            if let inAppPurchase = inAppPurchase {
                updateCellContent(inAppPurchase)
            }
        }
    }
    
    @IBOutlet var inAppPurchaseTitleLabel: UILabel!
    @IBOutlet var inAppPurchaseButton: PrimaryButton!
    
    override func layoutSubviews() {
        let theme = Injection.theme
        
        inAppPurchaseTitleLabel.textColor = theme.textColor
        backgroundColor = theme.backgroundColor
        
        super.layoutSubviews()
        inAppPurchaseButton.isUserInteractionEnabled = false
    }
    
    
    private func updateCellContent(_ inAppPurchase: InAppPurchase) {
        let theme = Injection.theme
        inAppPurchaseTitleLabel?.text = inAppPurchase.title
        if inAppPurchase.isOwned {
            inAppPurchaseTitleLabel?.textColor = .lightGray
            inAppPurchaseButton?.setTitle("(Owned)", for: .normal)
            inAppPurchaseButton?.backgroundColor = theme.backgroundColor
            inAppPurchaseButton.setTitleColor(.white, for: .normal)
            self.isUserInteractionEnabled = false

        } else {
            inAppPurchaseTitleLabel?.textColor = Injection.theme.textColor
            inAppPurchaseButton?.setTitle(inAppPurchase.priceString, for: .normal)
            inAppPurchaseButton?.backgroundColor = Injection.theme.tintColor
            inAppPurchaseButton?.setTitleColor(.white, for: .normal)
            self.isUserInteractionEnabled = true
        }
    }

}
