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
    
    private var hasRezised: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.backgroundColor = Injection.theme.tintColor
        nextButton.addTarget(self, action: #selector(OnboardingViewController.nextButtonPressed), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        applyTheme()

        resizeForIphoneSE()
    }
    
    func applyTheme() {
        let theme = Injection.theme
        view.backgroundColor = theme.backgroundColor
        
        // recursively style all subviews
        styleSubview(view: view)
        
        navigationController?.navigationBar.barTintColor = theme.textColor
        navigationController?.navigationBar.tintColor = theme.tintColor
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: theme.textColor]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: theme.textColor]
            navBarAppearance.backgroundColor = theme.backgroundColor
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        } else {
            // Fallback on earlier versions
            UIApplication.shared.statusBarStyle = theme.statusBarStyle
        }
    }
    
    func styleSubview(view: UIView) {
        let theme = Injection.theme
        view.backgroundColor = theme.backgroundColor
        for subview in view.subviews {
            if subview.subviews.count == 0 {
                subview.backgroundColor = theme.backgroundColor
                
                if let label = subview as? UILabel {
                    label.textColor = theme.textColor
                }
                if let button = subview as? UIButton {
                    button.backgroundColor = theme.tintColor
                }
            } else {
                styleSubview(view: subview)
            }
        }
    }
    
    private func resizeForIphoneSE() {
        if hasRezised {
            return
        }
        
        hasRezised =  true
        let width = UIScreen.main.bounds.width
        if width > 320 {
            return
        }
        
        resizeView(view)
    }
    
    private func resizeView(_ view: UIView) {
        if let label = view as? UILabel {
            let fontsize = label.font.pointSize - 2.5
            label.font = label.font.withSize(fontsize)
        }
        if let stackView = view as? UIStackView {
            let spacing = stackView.spacing - 12.0
            stackView.spacing = spacing
        }
        
        for subview in view.subviews {
            resizeView(subview)
        }
    }
    
    @objc func nextButtonPressed(_ sender: Any) {
        onboardingDelegate?.nextButtonPressed()
    }
    
    
}
