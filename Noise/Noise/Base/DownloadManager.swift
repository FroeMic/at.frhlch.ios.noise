//
//  DownloadManager.swift
//  Noise
//
//  Created by Michael Fröhlich on 24.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation
import UIKit

class DownloadManager: NSObject {
    
    static let shared = DownloadManager()
    
    private var soundDownloadTasks: [Int: SoundDownloadTask] = [:]
    
    private var session : URLSession {
        get {
            let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
            
            // Warning: If an URLSession still exists from a previous download, it doesn't create
            // a new URLSession object but returns the existing one with the old delegate object attached!
            return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        }
    }
    
    func download(task: SoundDownloadTask) {
        let urlSessionTask = session.downloadTask(with: task.from)
        soundDownloadTasks[urlSessionTask.taskIdentifier] = task
        urlSessionTask.resume()
    }
    
    func movedFile(filename: String, for task: SoundDownloadTask) {
        SoundSyncManager.shared.downloadFinishedFor(task: task, with: filename)
    }
}

extension DownloadManager:  URLSessionDelegate {

}

extension DownloadManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let task = soundDownloadTasks.removeValue(forKey: downloadTask.taskIdentifier) else {
            return
        }
                
        var _filename: String? = nil
        if task.type == .mp3 {
            _filename = FileManager.default.moveToDocumentsDirectory(sourceLocation: location, filename: task.filename)
        } else {
            if let data = try? Data(contentsOf: location), let image = UIImage(data: data) {
                image.saveImage(name: task.filename)
                _filename = task.filename
            }
        }
        
        guard let filename = _filename else {
            try? FileManager.default.removeItem(at: location)
            return
        }
        
        movedFile(filename: filename, for: task)

    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        debugPrint("Task completed: \(task), error: \(String(describing: error))")
    }
    
    
}
