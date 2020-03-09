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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        applyTheme()
        super.viewWillAppear(animated)
    }
    
    func applyTheme() {
        let theme = Injection.theme
        
        view.backgroundColor = theme.backgroundColor
        textView.backgroundColor = theme.backgroundColor
        textView.textColor = theme.textColor
        textView.tintColor = theme.tintColor
        
    }
    
}
