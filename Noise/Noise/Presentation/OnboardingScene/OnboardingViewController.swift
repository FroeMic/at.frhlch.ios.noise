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

        resizeForIphoneSE()
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
