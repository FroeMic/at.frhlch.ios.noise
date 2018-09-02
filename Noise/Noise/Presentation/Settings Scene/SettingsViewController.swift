//
//  SettingsViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class SettingsViewController: UIViewController {
    
//    var player = AVPlayer(url: Injection.soundRepository.sounds[0].soundUrl!)
    
    var player: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVAudioSession()
        let url = Injection.soundRepository.sounds[0].soundUrl!
        player = try! AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
        
        player.numberOfLoops = -1
        player.volume = 0.1
        player.prepareToPlay()
        
        player.play()
    }
    
    private func setupAVAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            debugPrint("AVAudioSession is Active and Category Playback is set")
            UIApplication.shared.beginReceivingRemoteControlEvents()
            setupCommandCenter()
        } catch {
            debugPrint("Error: \(error)")
        }
    }

    private func setupCommandCenter() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: "Your App Name"]

        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.player.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.player.pause()
            return .success
        }
    }

}
