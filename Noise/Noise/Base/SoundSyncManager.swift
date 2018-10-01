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
            if let _ = error {
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
                    soundRepository.save(sound, inBackground: true)
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
            if let _ = error {
                return
            }
            guard let data = data, let jsonData = try? JSON(data: data) else {
                return
            }
            guard let updatedSound = self.updateSound(sound, fromJSON: jsonData) else {
                return
            }
            
            if let inAppPurchaseID = updatedSound.inAppPurchaseId {
                var updatedSoundWithInAppPurchaseID = updatedSound
                StoreKitManager.shared.getPriceString(id: inAppPurchaseID, completion: { (priceString) in
                    if let priceString = priceString {
                        updatedSoundWithInAppPurchaseID.priceString = priceString
                        Injection.soundRepository.save(updatedSoundWithInAppPurchaseID, inBackground: true)
                        self.fetchImagesAndMp3(sound: updatedSoundWithInAppPurchaseID, jsonData: jsonData)
                    }
                })
            } else {
                Injection.soundRepository.save(updatedSound, inBackground: true)
                self.fetchImagesAndMp3(sound: updatedSound, jsonData: jsonData)
            }

        }
        
        task.resume()
        
    }
    
    private func fetchImagesAndMp3(sound: Sound, jsonData: JSON) {
        
        if let imageUrlString = jsonData["imageURL"].string, let imageUrl = URL(string: imageUrlString) {
            let downloadImageTask = SoundDownloadTask(fromSound: sound, type: .image, url: imageUrl)
            DownloadManager.shared.download(task: downloadImageTask)
        }
        if let soundUrlString = jsonData["soundURL"].string, let imageUrl = URL(string: soundUrlString) {
            let downloadMp3Task = SoundDownloadTask(fromSound: sound, type: .mp3, url: imageUrl)
            DownloadManager.shared.download(task: downloadMp3Task)
        }
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
        var inAppPurchaseId: String? = json["inAppPurchaseId"].string
        if inAppPurchaseId?.count == 0 {
            inAppPurchaseId = nil
        }
        var category: String? = json["category"].string
        if category?.count == 0 {
            category = nil
        }
        
        guard id == sound.id else {
            return nil
        }
        
        var updatedSound = sound
        
        updatedSound.title = title
        updatedSound.subtitle = subtitle
        updatedSound.detailDescription = detailDescription
        updatedSound.inAppPurchaseId = inAppPurchaseId
        updatedSound.category = category
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
                
        soundRepository.save(sound, inBackground: true)
    }
    
}
