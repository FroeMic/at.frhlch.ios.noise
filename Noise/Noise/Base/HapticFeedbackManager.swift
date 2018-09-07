//
//  HapticFeedbackManager.swift
//  Noise
//
//  Created by Michael Fröhlich on 07.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class HapticFeedbackManager: NSObject  {
    
    private let notification = UINotificationFeedbackGenerator()
    
    override init() {
        
    }
    
    func feedbackForPeek(success: Bool = true) {
        hapticFeedback(success: success)
    }
    
    private func hapticFeedback(success: Bool) {
        if success {
            notification.notificationOccurred(.success)
        } else {
            notification.notificationOccurred(.error)
        }
    }
    
}
