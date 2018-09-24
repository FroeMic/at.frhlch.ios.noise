//
//  SoundDownloadTask.swift
//  Noise
//
//  Created by Michael Fröhlich on 24.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

enum DownloadType {
    case mp3
    case image
    
    var pathExtension: String {
        switch self {
        case .mp3:
            return ".mp3"
        case .image:
            return ".png"
        }
    }
}

struct SoundDownloadTask {
    
    let id: String
    let from: URL
    let filename: String
    let type: DownloadType
    
    init(fromSound sound: Sound, type: DownloadType, url: URL ) {
        self.id = sound.id
        self.filename = id + type.pathExtension
        self.from = url
        self.type = type
    }
}
