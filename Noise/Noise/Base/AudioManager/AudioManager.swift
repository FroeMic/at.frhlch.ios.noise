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
    
    private var players: [String: AVAudioPlayer] = [:]
    private var currentAudio: AudioBundle?
    private var previewPlayer: AudioManager?
    private var continueAfterPreview: Bool = false
    private var fallbackImage: UIImage = UIImage(named: "placeholder_artwork")!
    private var enableNextPrevTracks: Bool = false
    
    private var session: AVAudioSession {
        return AVAudioSession.sharedInstance()
    }

    private var playsInBackground: Bool {
        return Injection.settingsRepository.getBackgroundPlay()
    }
    
    private var delegates: [AudioManagerDelegate?] = []
    
    private(set) var state: AudioManagerState = .stopped {
        didSet {
            for delegate in delegates {
                delegate?.audioManager(self, didChange: state)
            }
        }
    }
    
    var sounds: [Sound]  {
        return currentAudio?.sounds ?? []
    }
    var displayTitle: String {
        return currentAudio?.displayTitle ?? "Not Playing"
    }
    var displayArtist: String {
        return currentAudio?.artist ?? "Noise"
    }
    var displayImage: UIImage {
        return currentAudio?.albumImage ?? fallbackImage
    }
    
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
        if !playsInBackground {
            return
        }
        
        updateNowPlayingInfo()
        
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
        commandCenter.nextTrackCommand.isEnabled = enableNextPrevTracks
        commandCenter.previousTrackCommand.isEnabled = enableNextPrevTracks
        commandCenter.nextTrackCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let self = self else {
                return .commandFailed
            }
            
            for delegate in self.delegates {
                delegate?.audioManager(self, didPressNextTrack: true)
            }
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let self = self else {
                return .commandFailed
            }
            for delegate in self.delegates{
                delegate?.audioManager(self, didPressPrevTrack: true)
            }
            return .success
        }
    }
    
    private func updateNowPlayingInfo() {
        if !playsInBackground {
            return
        }
        
        let artwork = MPMediaItemArtwork.init(boundsSize: displayImage.size, requestHandler: { (size) -> UIImage in
            return self.displayImage
        })
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: displayTitle,
            MPMediaItemPropertyArtist: displayArtist,
            MPMediaItemPropertyArtwork: artwork]
    }
    
    private func makePreviewAudioBundle(sounds: [Sound]) -> AudioBundle {
        return AudioBundle(id: "xxx-preview-sound", title: "Preview Sounds", sounds: sounds)
    }
    
    // MARK: Exposed functions
    
    func register(delegate: AudioManagerDelegate) {
        if delegates.contains(where: { $0 === delegate } ) {
            return
        }
        delegates.append(delegate)
    }
    
    func deregister(delegate: AudioManagerDelegate)  {
        delegates.removeAll(where: { $0 === delegate })
    }
    
    func activate(audio: AudioBundle, hard: Bool = true) {
        
        if hard {
            // 1. stop all players
            stop()
            
            // 2. (re)start with new audioBundle
            currentAudio = audio
            updateNowPlayingInfo()
            
            for sound in sounds {
                if let player = setupPlayerFor(sound: sound) {
                    players[sound.id] = player
                }
            }
        } else {
            // 1. remove all stale players
            for playerId in players.keys {
                if let _ = audio.sounds.firstIndex(where: { $0.id == playerId }) {
                    // do nothing
                } else {
                    players[playerId]?.stop()
                    players.removeValue(forKey: "playerId")
                }
            }
            
            // 2. Add or update all existing players

            for sound in audio.sounds {
                if let player = players[sound.id] {
                    player.volume = sound.volume
                } else {
                    if let player = setupPlayerFor(sound: sound) {
                        players[sound.id] = player
                    }
                }
            }
            
            currentAudio = audio
            updateNowPlayingInfo()
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
        updateNowPlayingInfo()
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
        guard let index = currentAudio?.sounds.index(of: sound) else {
            return
        }
        
        currentAudio?.sounds[index] = sound
        player.volume = sound.volume
    }
    
    public func preview(sounds: [Sound]) {
        if sounds.count < 1 {
            return
        }
        
        if state == .playing {
            pause()
            continueAfterPreview = true
        }
        
        if let previewPlayer = previewPlayer {
            previewPlayer.stop()
        }
        
        previewPlayer = AudioManager()
        previewPlayer?.activate(audio: makePreviewAudioBundle(sounds: sounds))
        previewPlayer?.play()
    }
    
    public func stopPreview() {
        if let previewPlayer = previewPlayer {
            previewPlayer.stop()
        }
        previewPlayer = nil
        
        if state == .paused && continueAfterPreview {
            continueAfterPreview = false
            play()
        }
    }
    
}

extension AudioManager {
    
    func isMixtapeActive(mixtape: Mixtape) -> Bool {
        return currentAudio?.id == mixtape.id
    }
    
}
