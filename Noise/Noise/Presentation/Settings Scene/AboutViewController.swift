//
//  AboutViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 24.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet var textView: UITextView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "About"
        applyTheme()
    }
    
    func applyTheme() {
        let theme = Injection.theme
        
        textView.textColor = theme.textColor
        textView.tintColor = theme.tintColor

    }
    
}
