//
//  PlayingView.swift
//  Noise
//
//  Created by Michael Fröhlich on 07.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit
import Lottie

class CassetteView: UIView {
    
    private var animationView: LOTAnimationView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupAnimationView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupAnimationView()
    }
    
    private func setupAnimationView() {
        
        let animationView = LOTAnimationView(name: "cassette")
        animationView.contentMode = .scaleAspectFit
        animationView.loopAnimation = true
        animationView.animationSpeed = 1.0
        animationView.frame = bounds
        addSubview(animationView)
        
        self.animationView = animationView
    }
    
    
    func applyTheme() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        applyTheme()
    }
    
    func playAnimation() {
        animationView?.play()
    }
    
    func stopAnimation() {
        animationView?.stop()

    }
    
}

