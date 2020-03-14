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
    
    private var enforceNoBackgroundPlay: Bool = false
    private var players: [String: AVAudioPlayer] = [:]
    private var currentAudio: AudioBundle?
    private var previewPlayer: AudioManager?
    private var continueAfterPreview: Bool = false
    private var continueAfterMovingToForeground: Bool = false
    private var fallbackImage: UIImage = UIImage(named: "placeholder_artwork")!
    private var commandCenterHasTargets: Bool = false
    private var limitPreview: Bool = false
    private var shouldRestartPreview: Bool = false
    
    private var session: AVAudioSession {
        return AVAudioSession.sharedInstance()
    }

    private var playsInBackground: Bool {
        return !enforceNoBackgroundPlay && Injection.settingsRepository.getBackgroundPlay()
    }
    
    private var delegates: [AudioManagerDelegate?] = []
    
    private(set) var state: AudioManagerState = .stopped {
        didSet {
            for delegate in delegates {
                delegate?.audioManager(self, didChange: state)
            }
        }
    }
    
    var enableNextPrevTracks: Bool = false

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
    
    private init(enforceNoBackgroundPlay: Bool = false) {
        self.enforceNoBackgroundPlay = enforceNoBackgroundPlay
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillMoveToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidMoveToForground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)

        setupAudioSession()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    @objc func appWillMoveToBackground() {
        stopPreview()
        if !playsInBackground && state == .playing {
            continueAfterMovingToForeground = true
            pause()
        }
    }
    
    @objc func appDidMoveToForground() {
        if continueAfterMovingToForeground {
            continueAfterMovingToForeground = false
            play()
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
        commandCenter.nextTrackCommand.isEnabled = enableNextPrevTracks
        commandCenter.previousTrackCommand.isEnabled = enableNextPrevTracks
        
        // make sure targets are added only once
        if commandCenterHasTargets {
            return
        }
        commandCenterHasTargets = true
        
        commandCenter.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.pause()
            return .success
        }
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
    
    func prepareForActivation(audio: AudioBundle) {
        if state == .playing {
            debugPrint("Cannot prepare. Already active")
        }
        
        DispatchQueue.global(qos: .utility).async {
                
            for sound in audio.sounds {
                if let player = self.players[sound.id] {
                    player.volume = sound.volume
                } else {
                    if let player = self.setupPlayerFor(sound: sound) {
                        self.players[sound.id] = player
                    }
                }
            }
            self.currentAudio = audio
        }
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
                    players.removeValue(forKey: playerId)
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
        debugPrint("Audiomanager.play()")
        updateNowPlayingInfo()
        DispatchQueue.global(qos: .userInteractive).async {
            self.players.values.forEach { $0.play() }
        }
        
        state = .playing
    }
    
    public func stop() {
        debugPrint("Audiomanager.stop()")
        DispatchQueue.global(qos: .userInteractive).async {
            let oldplayers = self.players
            self.players = [:]
            self.currentAudio = nil
            oldplayers.values.forEach { $0.stop() }
        }
        
        state = .stopped
    }
    
    public func pause() {
        debugPrint("Audiomanager.pause()")
        DispatchQueue.global(qos: .userInteractive).async {
            self.players.values.forEach { $0.pause() }
        }
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
        } else {
            // only create once
            previewPlayer = AudioManager(enforceNoBackgroundPlay: true)
        }
        
        var shouldLimit = false
        if let firstSound = sounds.first {
            shouldLimit = !StoreKitManager.shared.doesHaveAccessToSound(sound: firstSound)
        }
        
        self.limitPreview = shouldLimit
        self.shouldRestartPreview = shouldLimit
        
        previewPlayer?.activate(audio: makePreviewAudioBundle(sounds: sounds))
        previewPlayer?.play()
        
        if limitPreview {
            previewWithLimit()
        }
    }
    
    private func previewWithLimit() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 8, execute: {
            self.previewPlayer?.pause()
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
                if self.shouldRestartPreview {
                    self.previewPlayer?.play()
                    self.previewWithLimit()
                }
            })
        })
    }
    
    public func stopPreview() {
        if let previewPlayer = previewPlayer {
            limitPreview = false
            shouldRestartPreview = false
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
    
    func isMixtapeActive(id: String) -> Bool {
        return currentAudio?.id == id
    }
    
}
