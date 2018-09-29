//
//  InAppPurchase.swift
//  Noise
//
//  Created by Michael Fröhlich on 29.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

struct InAppPurchase {
    
    let id: String
    let title: String
    private (set) var priceString: String

    
    var isOwned: Bool {
        return StoreKitManager.shared.doesHaveAccessToId(id: id)
    }
    
    init(id: String, title: String, priceString: String) {
        self.id = id
        self.title = title
        self.priceString = priceString
        
        
    }

    
}

extension InAppPurchase {
    
    init?(sound: Sound) {
        guard let inAppPurchaseId = sound.inAppPurchaseId, let priceString = sound.priceString else {
            return nil
        }
        
        self.init(id: inAppPurchaseId, title: sound.title, priceString: priceString)
    }
    
}
