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
        
        audioManager.register(delegate: self)
        updateSoundBar(with: audioManager)
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
    
    private func getMixtape(offset: Int) -> Mixtape? {
        let mixtapes: [Mixtape] = Injection.mixtapeRepository.getAll().filter( {$0.sounds.count > 0 })
        guard let index = mixtapes.firstIndex(where: { AudioManager.shared.isMixtapeActive(mixtape: $0) }) else {
            return mixtapes.first
        }
        let nextIndex = (index + offset) % mixtapes.count
        
        return mixtapes[nextIndex]
    }
    
    func updateSoundBar(with audioManager: AudioManager) {
        soundToolbar.title = audioManager.displayTitle
        soundToolbar.state = audioManager.state
        
        let mixtapes: [Mixtape] = Injection.mixtapeRepository.getAll()
        soundToolbar?.hasNextTrack = mixtapes.count > 1
        soundToolbar?.hasPrevTrack = mixtapes.count > 1
        audioManager.enableNextPrevTracks = mixtapes.count > 1
    }
    
}

extension BaseTabBarController: AudioManagerDelegate {
    
    func audioManager(_ audioManager: AudioManager, didChange state: AudioManagerState) {
        updateSoundBar(with: audioManager)
    }
    
    func audioManager(_ audioManager: AudioManager, didPressNextTrack: Bool) {
        self.didPressNextTrack()
    }
    
    func audioManager(_ audioManager: AudioManager, didPressPrevTrack: Bool){
        self.didPressPreviousTrack()
    }
    
}

extension BaseTabBarController: SoundBarDelegate {
    
    func didSelectSoundBar() {
        // Todo
    }
    
    func didPressPause() {
        audioManager.pause()
        Injection.feedback.subtleFeedback()
    }
    
    func didPressPlay() {
        Injection.feedback.subtleFeedback()
        if audioManager.state == .stopped {
            guard let mixtape = getMixtape(offset: 0) else {
                let sounds = Injection.soundRepository.getAll()
                let audioBundle = AudioBundle(id: "xxx-noise-all-sounds", title: "Ambient Sound Mix" , sounds: sounds)
                audioManager.activate(audio: audioBundle, hard: false)
                return
            }
            audioManager.activate(audio: AudioBundle(mixtape: mixtape), hard: false)
        } else {
            audioManager.play()
        }
    }
    
    func didPressNextTrack() {
        guard let mixtape = getMixtape(offset: 1) else {
            return
        }
        AudioManager.shared.activate(audio: AudioBundle(mixtape: mixtape))
        Injection.feedback.subtleFeedback()
    }
    
    func didPressPreviousTrack() {
        guard let mixtape = getMixtape(offset: -1) else {
            return
        }
        AudioManager.shared.activate(audio: AudioBundle(mixtape: mixtape))
        Injection.feedback.subtleFeedback()
    }
    
}
