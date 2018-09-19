//
//  PlayingView.swift
//  Noise
//
//  Created by Michael Fröhlich on 07.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON

class PlayingView: UIView {
    
    private static var jsonAnimation: JSON?
    private static var currentColor: UIColor?
    
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
        
        let color = Injection.theme.tintColor
        if PlayingView.jsonAnimation == nil {
            updateColor(color)
        } else if color != PlayingView.currentColor {
            updateColor(color)
        }
        
        let animationView: LOTAnimationView
        if let json = PlayingView.jsonAnimation?.dictionaryObject {
            animationView = LOTAnimationView(json: json)
        } else {
            animationView = LOTAnimationView(name: "playing")
        }

        animationView.contentMode = .scaleAspectFit
        animationView.loopAnimation = true
        animationView.animationSpeed = 1.3
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
    
    func updateColor(_ color: UIColor) {
        guard  let path = Bundle.main.path(forResource: "playing", ofType: "json")  else {
            return
        }
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else {
            return
        }
        
        guard var json = try? JSON(data: data) else {
            return
        }
        
        let colorLiteral = [color.red, color.green, color.blue, 1.0]
        
        if let _ = json["assets"][0]["layers"][0]["shapes"][1]["c"]["k"].array {
            json["assets"][0]["layers"][0]["shapes"][1]["c"]["k"] = JSON(colorLiteral)
        }
        if let _ = json["assets"][1]["layers"][0]["shapes"][1]["c"]["k"].array {
            json["assets"][1]["layers"][0]["shapes"][1]["c"]["k"] = JSON(colorLiteral)
        }
        if let _ = json["assets"][2]["layers"][0]["shapes"][1]["c"]["k"].array {
            json["assets"][2]["layers"][0]["shapes"][1]["c"]["k"] = JSON(colorLiteral)
        }
        
        PlayingView.jsonAnimation = json
        PlayingView.currentColor = color
        
    }
    
}

private extension UIColor {
    
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    
    var red: Double {
        return Double(coreImageColor.red)
    }
    
    var green: Double {
        return Double(coreImageColor.green)
    }
    
    var blue: Double {
        return Double(coreImageColor.blue)
    }
}
