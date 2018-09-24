//
//  Filemanager+Filepath.swift
//  Noise
//
//  Created by Michael Fröhlich on 21.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

extension FileManager {
    
    func getDocumentsURL() -> URL {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        return documentsURL as URL
    }
    
    func filepathFromDocumentsDirectoryOrBundle(filename: String) -> String? {
        
        let documentsUrl = getDocumentsURL().appendingPathComponent(filename)
        
        if fileExists(atPath: documentsUrl.path) {
            return documentsUrl.path
        }
        
        if let bundlePath = Bundle.main.path(forResource: filename, ofType: nil) {
            return bundlePath
        }
        
        return nil
    }
    
    func moveToDocumentsDirectory(sourceLocation: URL, filename: String) -> String? {
        do {
            let destinationLocation = getDocumentsURL().appendingPathComponent(filename)
            try moveItem(at: sourceLocation, to: destinationLocation)
            return destinationLocation.lastPathComponent
        } catch {
            return nil
        }
    }
}
