//
//  LicenseDetailViewController.swift
//  ping
//
//  Created by Michael Fröhlich on 05.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class LicenseDetailViewController: UIViewController {
    
    var license: License? {
        didSet {
            updateContent()
        }
    }
    
    @IBOutlet var licenseTitleLabel: UILabel!
    @IBOutlet var licenseUrlTextView: UITextView!
    @IBOutlet var licenseTextView: UITextView!
    @IBOutlet var licenseUrlTextViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        updateContent()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        applyTheme()
        
        // Show the Navigation Bar
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        super.viewWillAppear(animated)

    }
    
    override func viewWillLayoutSubviews() {
        licenseUrlTextViewHeightConstraint.constant = licenseUrlTextView.intrinsicContentSize.height
        licenseTextView?.setContentOffset(.zero, animated: false)
        
        super.viewWillLayoutSubviews()
    }
    
    func applyTheme() {
        let theme = Injection.theme
        
        // Show the Navigation Bar
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = theme.backgroundColor
        navigationController?.navigationBar.tintColor = theme.tintColor
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()


        view.backgroundColor = theme.backgroundColor
        licenseTitleLabel.backgroundColor = theme.backgroundColor
        licenseUrlTextView.backgroundColor = theme.backgroundColor
        licenseUrlTextView.backgroundColor = theme.backgroundColor
        licenseTitleLabel.textColor = theme.textColor
        licenseUrlTextView.textColor = theme.textColor
        licenseUrlTextView.tintColor = theme.tintColor
        licenseTextView.textColor = theme.textColor
        licenseTextView.tintColor = theme.tintColor

    }
    
    func updateContent() {
        guard let license = license else {
            return
        }
        
        
        title = license.title
        
        licenseTitleLabel?.text = license.title
        licenseUrlTextView?.text = license.url
        licenseTextView?.text = license.license
        
        licenseTextView?.setContentOffset(.zero, animated: false)
    }
    
}

