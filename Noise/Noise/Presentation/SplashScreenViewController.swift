//
//  SplashScreenViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 24.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit
import Presentation

class SplashScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Injection.settingsRepository.getShowOnboarding() {
            presentOnboarding()
        } else {
            presentMainApp()
        }
    }

    private func presentMainApp() {
        self.performSegue(withIdentifier: "presentMainApp", sender: nil)
    }
    
    private func presentOnboarding() {
        let presentationController = OnboardingPresentationController()
        self.present(presentationController, animated: true)
    }
    
  
}
