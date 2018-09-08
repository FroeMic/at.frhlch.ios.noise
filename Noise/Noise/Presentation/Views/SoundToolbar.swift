//
//  SoundToolbar.swift
//  Noise
//
//  Created by Michael Fröhlich on 08.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class SoundBar: UIToolbar {
    
    var soundBarDelegate: SoundBarDelegate?
    var hasNextTrack = false {
        didSet {
            nextButton?.isEnabled = hasNextTrack
        }
    }
    var hasPrevTrack = false {
        didSet {
            prevButton?.isEnabled = hasPrevTrack
        }
    }
    
    var title: String? {
        didSet {
            titleLabel?.text = self.title ?? "Not Playing"
        }
    }
    var state: AudioManagerState = .stopped {
        didSet {
            if state == .playing {
                playButton?.image = UIImage(named: "ic_pause")
                cassetteView?.playAnimation()
            } else {
                playButton?.image = UIImage(named: "ic_play")
                cassetteView?.stopAnimation()
            }
        }
    }

    private var titleLabel: UILabel?
    private var cassetteView: CassetteView?
    private var playButton: UIBarButtonItem?
    private var nextButton: UIBarButtonItem?
    private var prevButton: UIBarButtonItem?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
       
        tintColor = .black
        
        let playButton = UIBarButtonItem(image: UIImage(named: "ic_play"), style: .plain, target: self, action: #selector(SoundBar.playButtonPressed))
        self.playButton = playButton
        let nextButton = UIBarButtonItem(image: UIImage(named: "ic_next_track"), style: .plain, target: self, action: #selector(SoundBar.nextTrackButtonPressed))
        nextButton.isEnabled = false
        self.nextButton = nextButton
        let prevButton = UIBarButtonItem(image: UIImage(named: "ic_prev_track"), style: .plain, target: self, action: #selector(SoundBar.prevTrackButtonPressed))
        prevButton.isEnabled = false
        self.prevButton = prevButton
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let titleLabel = UILabel()
        titleLabel.font = titleLabel.font.withSize(11.0)
        titleLabel.frame = CGRect(x: 0, y: 0, width: 170, height: titleLabel.bounds.height)
        titleLabel.text = self.title ?? "Not Playing"
        self.titleLabel = titleLabel
        
        let title = UIBarButtonItem(customView: titleLabel)
        
//        let cassetteView = CassetteView(frame: CGRect(x: 0, y: 0, width: 30.0, height: 30.0))
//        let cassette = UIBarButtonItem(customView: cassetteView)
//        self.cassetteView = cassetteView
//
//        let fixedSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        fixedSpacer.width = 5
        
        setItems([title, spacer, prevButton, playButton,nextButton], animated: false)
        
    }
    
    
    // MARK: User Interaction
    @objc func playButtonPressed() {
        if state == .playing {
            soundBarDelegate?.didPressPause()
        } else {
            soundBarDelegate?.didPressPlay()
        }
    }
    @objc func nextTrackButtonPressed() {
        soundBarDelegate?.didPressNextTrack()
    }
    @objc func prevTrackButtonPressed() {
        soundBarDelegate?.didPressPreviousTrack()
    }
}
