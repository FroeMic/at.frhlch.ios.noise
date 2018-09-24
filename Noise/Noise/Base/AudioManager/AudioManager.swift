//
//  AudioManager.swift
//  Noise
//
//  Created by Michael Fröhlich on 02.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class AudioManager {
    
    static let shared = AudioManager()
    
    var delegate: AudioManagerDelegate?
    
    private let playsInBackground: Bool
    private var previewPlayer: AudioManager?
    private(set) var state: AudioManagerState = .stopped {
        didSet {
            delegate?.audioManager(self, didChange: state)
        }
    }
    
    private var session: AVAudioSession {
        return AVAudioSession.sharedInstance()
    }
    private var players: [String: AVAudioPlayer] = [:]
    private var sounds: [Sound] = []
    private (set) var title: String = ""
    private (set) var image: UIImage = UIImage(named: "placeholder_artwork")!
    
    private init(playsInBackground: Bool = true) {
        self.playsInBackground = playsInBackground
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
        if !playsInBackground {
            return
        }
        
        updateNowPlayingInfo(title: title, image: image)
        
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
    
    private func updateNowPlayingInfo(title: String, image: UIImage) {
        if playsInBackground {
            let artwork = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { (size) -> UIImage in
                return image
            })
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: title,
                MPMediaItemPropertyArtist: "Noise",
                MPMediaItemPropertyArtwork: artwork]
        }
    }
    
    // MARK: Exposed functions
    func activate(sounds: [Sound], title: String, image: UIImage? = nil) {

        updateNowPlayingInformation(title: title, image: image)
        
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
        updateNowPlayingInfo(title: title, image: image)
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
    
    public func updateNowPlayingInformation(title: String, image: UIImage? = nil) {
        self.title = title
        self.image = image ?? UIImage(named: "placeholder_artwork")!
        updateNowPlayingInfo(title: title, image: self.image)
    }
    
    public func preview(sounds: [Sound], title: String = "Preview", image: UIImage? = nil) {
        pause()
        if let previewPlayer = previewPlayer {
            previewPlayer.stop()
        }
        previewPlayer = AudioManager(playsInBackground: true)
        previewPlayer?.activate(sounds: sounds, title: title, image: image)
        previewPlayer?.play()
    }
    
    public func stopPreview() {
        if let previewPlayer = previewPlayer {
            previewPlayer.stop()
        }
        previewPlayer = nil
        
        if state == .paused {
            play()
        }
    }
    
}
