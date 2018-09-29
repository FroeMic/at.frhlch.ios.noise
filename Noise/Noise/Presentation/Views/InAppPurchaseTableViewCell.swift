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
        super.layoutSubviews()
        inAppPurchaseButton.isUserInteractionEnabled = false
    }
    
    
    private func updateCellContent(_ inAppPurchase: InAppPurchase) {
        inAppPurchaseTitleLabel?.text = inAppPurchase.title
        if inAppPurchase.isOwned {
            inAppPurchaseTitleLabel?.textColor = .lightGray
            inAppPurchaseButton?.setTitle("(Owned)", for: .normal)
            inAppPurchaseButton?.backgroundColor = .white
            inAppPurchaseButton.setTitleColor(.lightGray, for: .normal)
            self.isUserInteractionEnabled = false

        } else {
            inAppPurchaseTitleLabel?.textColor = .black
            inAppPurchaseButton?.setTitle(inAppPurchase.priceString, for: .normal)
            inAppPurchaseButton?.backgroundColor = .lightGray
            inAppPurchaseButton?.setTitleColor(.white, for: .normal)
            self.isUserInteractionEnabled = true
        }
    }

}
