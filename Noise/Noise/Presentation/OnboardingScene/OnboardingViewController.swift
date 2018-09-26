//
//  OnboardingViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 26.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController  {
    
    var onboardingDelegate: OnboardingDelegate?
    
    @IBOutlet var nextButton: PrimaryButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.backgroundColor = Injection.theme.tintColor
        nextButton.addTarget(self, action: #selector(OnboardingViewController.nextButtonPressed), for: .touchUpInside)
    }
    
    @objc func nextButtonPressed(_ sender: Any) {
        onboardingDelegate?.nextButtonPressed()
    }
    
    
}
