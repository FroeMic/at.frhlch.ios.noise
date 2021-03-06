//
//  NoisePreviewViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 07.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class NoisePreviewViewController: UIViewController, InterfaceThemeSubscriber {
    
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
    @IBOutlet var connectingView: UIView!
    
    @IBOutlet var headerViewRelativeHeightConstraint: NSLayoutConstraint!
    
    private var didMoveToBackground: Bool = false
    private var hasResized = false
    
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
        
        connectingView.isHidden = true
        
        resizeForIphoneSE()
        
        Injection.themePublisher.subscribeToThemeUpdates(self)
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
            buyThisSoundViewContainer.alpha = 0
        } else if sound.isPremium {
            premiumLabel?.text = "Preview limited to 8 seconds."
            buyThisSoundViewContainer.alpha = 1
            buyThisSoundLabel?.text = sound.title
            buyPremiumLabel?.text = "Noise Premium"
            buyThisSoundButton.setTitle(sound.priceString, for: .normal)
            buyPremiumButton.setTitle(StoreKitManager.shared.premiumPrice, for: .normal)
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
    
    func applyTheme() {
        let theme = Injection.theme
        
        view.backgroundColor = theme.backgroundColor
        imageContainer.backgroundColor = theme.backgroundColor
        playingView.backgroundColor = theme.backgroundColor
        descriptionLabel.textColor = theme.textColor
        closeButton?.backgroundColor = theme.tintColor
        buyPremiumButton?.backgroundColor = theme.tintColor
        buyThisSoundButton?.backgroundColor = theme.tintColor
        buyThisSoundLabel?.textColor = theme.textColor
        buyPremiumLabel?.textColor = theme.textColor
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        Injection.feedback.subtleFeedback()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressBuyThisSound(_ sender: Any) {
        guard let sound = sound, let inAppPurchaseId = sound.inAppPurchaseId else{
            return
        }

        connectingView.isHidden = false
        StoreKitManager.shared.purchaseProduct(id: inAppPurchaseId, completion: { success in
            self.updateView()
            self.connectingView.isHidden = true
            self.previewSound()
        })
    }
    
    @IBAction func didPressBuyPremium(_ sender: Any) {
        connectingView.isHidden = false

        StoreKitManager.shared.purchasePremium(completion: { success in
            self.updateView()
            self.connectingView.isHidden = true
            self.previewSound()
        })
    }
}

extension NoisePreviewViewController {
    private func resizeForIphoneSE() {
        if hasResized {
            return
        }
        
        hasResized =  true
        headerViewRelativeHeightConstraint.constant = -25
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
            let spacing = stackView.spacing - 2.0
            stackView.spacing = spacing
        }
        
        for subview in view.subviews {
            resizeView(subview)
        }
    }
}
