//
//  OnboardingPresentationController.swift
//  Noise
//
//  Created by Michael Fröhlich on 26.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation
import Presentation

class OnboardingPresentationController: PresentationController {
    
    private let dismissOnCompletion: Bool
    
    init(dismissOnCompletion: Bool = false) {
        self.dismissOnCompletion = dismissOnCompletion
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        initPages()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        view.backgroundColor = Injection.theme.backgroundColor
        
        super.viewWillAppear(animated)
    }
    
    private func styleView() {
        let pageControl = UIPageControl.appearance()
        pageControl.currentPageIndicatorTintColor = Injection.theme.tintColor
        pageControl.pageIndicatorTintColor = .lightGray

        self.view.backgroundColor = .white
    }
    
    private func initPages() {
        let vc1 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardingVC1")
        let vc2 =  UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardingVC2")
        let vc3 =  UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardingVC3")
        let vc4 =  UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardingVC4")

        let viewControllers = [vc1, vc2, vc3, vc4]
        for vc in viewControllers  {
            if let vc = vc as? OnboardingViewController {
                vc.onboardingDelegate = self
            }
        }
        
        self.add(viewControllers)
        
    }
    
    private func presentMainApp() {
        let mainSceneVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BaseTabBarController")
        mainSceneVC.modalPresentationStyle = .fullScreen
        
        Injection.settingsRepository.setShowOnboarding(enabled: false)
        if dismissOnCompletion {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.present(mainSceneVC, animated: true)
        }
    }
}


extension OnboardingPresentationController: OnboardingDelegate {
    func nextButtonPressed() {
        if currentIndex == pagesCount-1 {
            presentMainApp()
        } else {
            moveForward()
        }
    }
    
}
