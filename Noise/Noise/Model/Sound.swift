//
//  Sound.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

struct Sound {
    
    let id: String
    var title: String
    var subtitle: String
    var detailDescription: String
    var imageFilePath: String?
    var soundFilePath: String?
    var inAppPurchaseId: String?
    var contentDownloaded: Bool
    var filesDownloaded: Bool
    var needsUpdate: Bool
    var volume: Float = 0
    var priceString: String?
    
    let image: UIImage?

    var isPremium: Bool {
        return inAppPurchaseId != nil
    }
    
    init?(managedSound: ManagedSound, withVolume: Float? = nil) {
        guard let id = managedSound.id else {
            return nil
        }
        guard let title = managedSound.title else {
            return nil
        }
        guard let subtitle = managedSound.subtitle else {
            return nil
        }
        guard let detailDescription = managedSound.detailedDescription else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.detailDescription = detailDescription
        self.imageFilePath = managedSound.imageFilePath
        self.soundFilePath = managedSound.soundFilePath
        self.inAppPurchaseId = managedSound.inAppPurchaseId
        self.contentDownloaded = managedSound.contentDownloaded
        self.filesDownloaded = managedSound.filesDownloaded
        self.needsUpdate = managedSound.needsUpdate
        self.volume = withVolume ?? managedSound.volume
        self.priceString =  managedSound.priceString
        if let imageFilePath = self.imageFilePath {
            self.image = UIImage(fromFile: imageFilePath)
        } else {
            self.image = nil
        }
    }
    
    init?(managedMixtapeSound: ManagedMixtapeSound) {
        guard let sound = managedMixtapeSound.sound else {
            return nil
        }
        self.init(managedSound: sound, withVolume: managedMixtapeSound.volume)
    }
    
    var soundUrl: URL? {
        guard let path = soundFilePath else {
            return nil
        }
        guard let filepath = FileManager.default.filepathFromDocumentsDirectoryOrBundle(filename: path) else {
            return nil
        }
        
        return URL(fileURLWithPath: filepath)
    }
    
}

extension Sound: Hashable {
    
}

extension Sound: Equatable {
    static func ==(lhs: Sound, rhs: Sound) -> Bool {
        return lhs.id == rhs.id
    }
}
