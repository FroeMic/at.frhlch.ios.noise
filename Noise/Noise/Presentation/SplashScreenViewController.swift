//
//  SplashScreenViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 24.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit
import WhatsNewKit

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
        let whatsNew = prepareOnboarding()
        
        // Initialize default Configuration
        var configuration = WhatsNewViewController.Configuration()
        

        // Initialize CompletionButton with title and custom action
        configuration.completionButton = WhatsNewViewController.CompletionButton(
            title: "Continue",
            action: .custom(action: { [weak self] whatsNewViewController in
                Injection.settingsRepository.setShowOnboarding(enabled: false)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "BaseTabBarController")
                whatsNewViewController.present(controller, animated: false, completion: nil)
                
            })
        )
        
        
        
        // Customize Configuration to your needs
//        configuration.backgroundColor = .white
//        configuration.titleView.titleColor = .orange
//        configuration.itemsView.titleFont = .systemFont(ofSize: 17)
//        configuration.detailButton.titleColor = .orange
//        configuration.completionButton.backgroundColor = .orange
//        // And many more configuration properties...
//
        configuration.theme.backgroundColor = UIColor.white
        
        // Initialize WhatsNewViewController with custom configuration
        let whatsNewViewController = WhatsNewViewController(
            whatsNew: whatsNew,
            configuration: configuration
        )
        
        // Present it 🤩
        self.present(whatsNewViewController, animated: true)
    }
    
    private func prepareOnboarding() -> WhatsNew {
        return WhatsNew(
            // The Title
            title: "Welcome",
            // The features you want to showcase
            items: [
                WhatsNew.Item(
                    title: "Noise",
                    subtitle: "Welcome to Noise",
                    image: UIImage(named: "ic_noise")
                ),

                
            ]
        )
    }
    
}
