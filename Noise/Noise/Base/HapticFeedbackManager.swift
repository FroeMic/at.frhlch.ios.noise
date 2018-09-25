//
//  HapticFeedbackManager.swift
//  Noise
//
//  Created by Michael Fröhlich on 07.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class HapticFeedbackManager: NSObject  {
    
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    override init() {
        
    }
    
    func feedbackForPeek(success: Bool = true) {
        if success {
            successFeedback()
        } else {
            failureFeedback()
        }
    }
    
    func subtleFeedback() {
        selectionGenerator.selectionChanged()
    }
    
    func successFeedback() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    func failureFeedback() {
        notificationGenerator.notificationOccurred(.error)
    }
    
}
