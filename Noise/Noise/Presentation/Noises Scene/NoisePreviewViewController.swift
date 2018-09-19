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
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var playingView: PlayingView!
    @IBOutlet var closeButton: PrimaryButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theme = Injection.theme
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        applyTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard var sound = sound else {
            return
        }
        
        // if a sound is muted we will preview it with the average volume of all positive sounds
        if sound.volume == 0 {
            var volume: Float = 0
            var count: Float = 0
            let sounds = Injection.soundRepository.getAll()
            for (_, sound) in  sounds{
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
            
            sound = sound.with(volume: volume)
        }
        
        imageView?.image = sound.image
        titleLabel?.text = sound.title
        descriptionLabel?.text = sound.description
        
        AudioManager.shared.preview(sounds: [sound], title: "Preview: " + sound.title)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AudioManager.shared.stopPreview()
    }
    
    private func applyTheme() {
        let theme = Injection.theme
        
        closeButton.backgroundColor = theme.tintColor
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
