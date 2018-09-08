//
//  BaseTabBarController.swift
//  Noise
//
//  Created by Michael Fröhlich on 02.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {
    
    var soundToolbar: SoundBar!
    var audioManager: AudioManager {
        return AudioManager.shared
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedIndex = 1
    
        soundToolbar = SoundBar(frame: CGRect(x: 0, y: view.bounds.height - tabBar.frame.height - 45.0 , width: view.bounds.width, height: 44.0))
        soundToolbar.soundBarDelegate = self 
        view.addSubview(soundToolbar)
        
        let constraints = [
            NSLayoutConstraint(item: soundToolbar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44.0),
            NSLayoutConstraint(item: soundToolbar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: soundToolbar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: soundToolbar, attribute: .bottom, relatedBy: .equal, toItem: tabBar, attribute: .top, multiplier: 1.0, constant: -1),
        ]
        
        soundToolbar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints(constraints)
        
        audioManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateSoundBar(with: audioManager)
    }
    
    func updateSoundBar(with audioManager: AudioManager) {
        soundToolbar.title = audioManager.title
        soundToolbar.state = audioManager.state
    }
    
}

extension BaseTabBarController: AudioManagerDelegate {
    
    func audioManager(_ audioManager: AudioManager, didChange state: AudioManagerState) {
        updateSoundBar(with: audioManager)
    }
    
}

extension BaseTabBarController: SoundBarDelegate {
    
    func didSelectSoundBar() {
        // Todo
    }
    
    func didPressPause() {
        audioManager.pause()
    }
    
    func didPressPlay() {
        audioManager.play()
    }
    
    func didPressNextTrack() {
        // Todo
    }
    
    func didPressPreviousTrack() {
        // Todo
    }
    
}
