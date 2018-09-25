//
//  SoundSyncManager.swift
//  Noise
//
//  Created by Michael Fröhlich on 24.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation
import SwiftyJSON

class SoundSyncManager {
    
    private let token = "21345678987654321345678976r5e4w3dsfghjghdgsfgdhfq"
    private var baseURL: String {
        return "https://frhlch.at/noise/sounds/" + token + "/"
    }
    private let revisionKey = "soundDataRevision"
    private var revision: Int {
        get {
            return UserDefaults.standard.integer(forKey: revisionKey)
        }
        set (revision) {
            UserDefaults.standard.set(revision, forKey: revisionKey)
        }
    }

    static let shared = SoundSyncManager()
    
    private init() {
        
    }
    
    func initiateServerSync(completion: ((Bool) -> Void)? = nil) {
        guard let targetURL = URL(string: baseURL) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: targetURL) { (data, response, error) in
            if let error = error {
                completion?(false)
            }
            guard let data = data, let jsonData = try? JSON(data: data) else {
                completion?(false)
                return
            }
            guard let serverRevision = jsonData["revision"].int,
                let jsonSoundIDs = jsonData["sounds"].array else {
                completion?(false)
                return
            }
            
            if serverRevision <= self.revision {
                completion?(true)
                return
            }
            
            let soundIDs = jsonSoundIDs.compactMap( { $0.string })
            let soundRepository = Injection.soundRepository
            for soundID in soundIDs {
                if var sound = soundRepository.get(id: soundID) {
                    sound.needsUpdate = true
                    soundRepository.save(sound)
                } else {
                    let _ = soundRepository.create(id: soundID)
                }
            }
            self.revision = serverRevision

            
            completion?(true)
        }
        
        task.resume()
    }
    
    func syncRequiredSounds() {
        let sounds = Injection.soundRepository.getAll(skipIncomplete: false)
        
        for sound in sounds {
            if !sound.filesDownloaded || sound.needsUpdate {
                syncDetailData(forSound: sound)
            }
        }
        
    }
    
    func syncDetailData(forSound sound: Sound) {
        guard let targetURL = URL(string: baseURL + sound.id) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: targetURL) { (data, response, error) in
            if let error = error {
                return
            }
            guard let data = data, let jsonData = try? JSON(data: data) else {
                return
            }
            guard let updatedSound = self.updateSound(sound, fromJSON: jsonData) else {
                return
            }
            
            Injection.soundRepository.save(updatedSound)
            
            if let imageUrlString = jsonData["imageURL"].string, let imageUrl = URL(string: imageUrlString) {
                let downloadImageTask = SoundDownloadTask(fromSound: updatedSound, type: .image, url: imageUrl)
                DownloadManager.shared.download(task: downloadImageTask)
            }
            if let soundUrlString = jsonData["soundURL"].string, let imageUrl = URL(string: soundUrlString) {
                let downloadMp3Task = SoundDownloadTask(fromSound: updatedSound, type: .mp3, url: imageUrl)
                DownloadManager.shared.download(task: downloadMp3Task)
            }
        }
        
        task.resume()
        
    }

    private func updateSound(_ sound: Sound, fromJSON json: JSON) -> Sound? {
        guard let id = json["id"].string else {
            return nil
        }
        guard let title = json["title"].string else {
            return nil
        }
        guard let subtitle = json["subtitle"].string else {
            return nil
        }
        guard let detailDescription = json["detailDescription"].string else {
            return nil
        }
        let inAppPurchaseId = json["inAppPurchaseId"].string
        
        guard id == sound.id else {
            return nil
        }
        
        var updatedSound = sound
        
        
        updatedSound.title = title
        updatedSound.subtitle = subtitle
        updatedSound.detailDescription = detailDescription
        updatedSound.inAppPurchaseId = inAppPurchaseId
        updatedSound.volume = 0
        updatedSound.contentDownloaded = true
                
        return updatedSound
    }

    
    func downloadFinishedFor(task: SoundDownloadTask, with filename: String) {
        let soundRepository = Injection.soundRepository
        guard var sound = soundRepository.get(id: task.id) else {
            return
        }
        if task.type == .image {
            sound.imageFilePath = filename
        }
        if task.type == .mp3 {
            sound.soundFilePath = filename
        }
        sound.filesDownloaded = sound.soundFilePath != nil && sound.imageFilePath != nil
        sound.needsUpdate = !sound.filesDownloaded
                
        soundRepository.save(sound)
    }
    
}
