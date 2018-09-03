//
//  AudioManager.swift
//  Noise
//
//  Created by Michael Fröhlich on 02.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation
import AVKit
import MediaPlayer

class AudioManager {
    
    static let shared = AudioManager()
    private(set) var state: AudioManagerState = .stopped

    
    private var session: AVAudioSession {
        return AVAudioSession.sharedInstance()
    }
    private var players: [String: AVAudioPlayer] = [:]
    private var sounds: [Sound] = []
    private var title: String = ""
    
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback,
                                     mode: AVAudioSessionModeDefault,
                                     routeSharingPolicy: .longForm,
                                     options: [])
        }
        catch let error {
            fatalError("*** Unable to set up the audio session: \(error.localizedDescription) ***")
        }
    }
    
    private func setupPlayerFor(sound: Sound) -> AVAudioPlayer? {
        guard let url = sound.soundUrl else {
            return nil
        }
        
        guard let player = try? AVAudioPlayer(contentsOf: url) else {
            return nil
        }
        
        player.numberOfLoops = -1
        player.volume = sound.volume
        player.prepareToPlay()
        
        return player
    }
    
    private func setupCommandCenter() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: title]
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.pause()
            return .success
        }
    }
    
    
    // MARK: Exposed functions
    func activate(sounds: [Sound], title: String) {

        if state == .playing {
            stop()
        }
        
        self.sounds = sounds
        
        for sound in sounds {
            if let player = setupPlayerFor(sound: sound) {
                players[sound.id] = player
            }
        }
        
        do {
            try session.setActive(true)
            debugPrint("AVAudioSession is Active and Category Playback is set")
            
            setupCommandCenter()
            
        } catch {
            debugPrint("Error: \(error)")
        }
        
        play()
    }
    
    public func play() {
        players.values.forEach { $0.play() }
        state = .playing
    }
    
    public func stop() {
        players.values.forEach { $0.stop() }
        
        players = [:]
        state = .stopped
    }
    
    public func pause() {
        players.values.forEach { $0.pause() }
        state = .paused
    }
    
    public func updateVolume(for sound: Sound) {
        guard let player = players[sound.id] else {
            return
        }
        
        guard let index = sounds.index(of: sound) else {
            return
        }
        sounds[index] = sound
        player.volume = sound.volume
    }
    
}
