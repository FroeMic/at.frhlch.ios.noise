//
//  PrivacyViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 02.10.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {
    
    @IBOutlet var textView: UITextView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Privacy Statement"
        applyTheme()
    }
    
    func applyTheme() {
        let theme = Injection.theme
        
        textView.textColor = theme.textColor
        textView.tintColor = theme.tintColor
        
    }
    
}
