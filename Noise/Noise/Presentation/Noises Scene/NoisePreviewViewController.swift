//
//  NoisePreviewViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 07.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class NoisePreviewViewController: UIViewController {
    
    var sound: Sound?
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageContainer: UIView!
    @IBOutlet var imageView: RoundedImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var premiumLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var playingView: PlayingView!
    @IBOutlet var closeButton: PrimaryButton!
    
    @IBOutlet var buyThisSoundViewContainer: UIView!
    @IBOutlet var buyThisSoundLabel: UILabel!
    @IBOutlet var buyThisSoundButton: PrimaryButton!
    @IBOutlet var buyPremiumLabel: UILabel!
    @IBOutlet var buyPremiumButton: PrimaryButton!
    
    
    private var didMoveToBackground: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theme = Injection.theme
        
        buyThisSoundViewContainer.alpha = 0
        
        titleLabel.textColor = theme.textColor
        descriptionLabel.textColor = theme.descriptionTextColor
        playingView.tintColor = theme.tintColor
        playingView.playAnimation()
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 3.0
        containerView.layer.shadowOffset = CGSize(width: 1.0, height: 3.0)
        
        let cornerRadius = min(containerView.frame.height, containerView.frame.width) * 0.05
        containerView.layer.cornerRadius = cornerRadius
        imageContainer.layer.cornerRadius = cornerRadius
        imageContainer.clipsToBounds = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillMoveToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillMoveToForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        applyTheme()
        updateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        previewSound()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillResignActive, object: nil)
        AudioManager.shared.stopPreview()
    }
    
    private func previewSound() {
        guard var sound = sound else {
            return
        }
        
        // if a sound is muted we will preview it with the average volume of all positive sounds
        if sound.volume == 0 {
            var volume: Float = 0
            var count: Float = 0
            let sounds = Injection.soundRepository.getAll()
            for (sound) in  sounds{
                if sound.volume > 0 {
                    volume += sound.volume
                    count += 1
                }
            }
            
            if count == 0 || volume == 0 {
                volume = 0.25
            } else {
                volume = volume / count
            }
            
            sound.volume = volume
        }
        
        AudioManager.shared.preview(sounds: [sound])
    }
    
    private func updateView() {
        guard let sound = sound else {
            return
        }
        
        imageView?.image = sound.image
        titleLabel?.text = sound.title + (sound.isPremium ? " (Premium)" : "")
        if StoreKitManager.shared.doesHaveAccessToSound(sound: sound) {
            premiumLabel?.text = ""
        } else if sound.isPremium {
            premiumLabel?.text = "Preview limited to 8 seconds."
            buyThisSoundViewContainer.alpha = 1
            buyThisSoundLabel?.text = sound.title
            buyPremiumLabel?.text = "Noise Premium"
            
        } else {
            premiumLabel?.text = ""
            
        }
        descriptionLabel?.text = sound.detailDescription
    }
    
    @objc func appWillMoveToBackground() {
        didMoveToBackground = true
    }
    
    @objc func appWillMoveToForeground() {
        if didMoveToBackground {
            didMoveToBackground = false
            previewSound()
            playingView.playAnimation()
        }
    }
    
    private func applyTheme() {
        let theme = Injection.theme
        
        closeButton.backgroundColor = theme.tintColor
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        Injection.feedback.subtleFeedback()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressBuyThisSound(_ sender: Any) {
        debugPrint("didPressPremium")
    }
    
    @IBAction func didPressBuyPremium(_ sender: Any) {
        debugPrint("didPressPremium")
    }
}
