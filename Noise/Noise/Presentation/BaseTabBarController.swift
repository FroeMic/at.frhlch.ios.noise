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
        
        selectedIndex = Injection.settingsRepository.getSelectedTab()
    
        soundToolbar = SoundBar(frame: CGRect(x: 0, y: view.bounds.height - tabBar.frame.height - 44.0 , width: view.bounds.width, height: 44.0))
        soundToolbar.soundBarDelegate = self 
        view.addSubview(soundToolbar)
        
        let constraints = [
            NSLayoutConstraint(item: soundToolbar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44.0),
            NSLayoutConstraint(item: soundToolbar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: soundToolbar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: soundToolbar, attribute: .bottom, relatedBy: .equal, toItem: tabBar, attribute: .top, multiplier: 1.0, constant: -0.34),
        ]
        
        soundToolbar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints(constraints)
        
        audioManager.delegates.append(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        applyTheme()
        updateSoundBar(with: audioManager)
    }
    
   override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let index = tabBar.items?.firstIndex(of: item) {
            Injection.settingsRepository.setSelectedTab(index: index)
        }
    }
    
    private func applyTheme() {
        let theme = Injection.theme
        
        tabBar.tintColor = theme.tintColor
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
