//
//  ViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit
import JustPeek

class NoiseViewController: UIViewController {
    
    static let soundReuseIdentifier = "SoundTableViewCell"

    @IBOutlet var tableView: UITableView!
    
    var peekController: PeekController?
    
    var sounds: [Sound] {
        return Injection.soundRepository.getAll().map { $0.1 }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playAudio()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        peekController = PeekController()
        peekController?.register(viewController: self, forPeekingWithDelegate: self, sourceView: tableView)
    }
    
    func playAudio() {
        AudioManager.shared.activate(sounds: sounds, title: "Noise Ambient Sounds")
    }
    
    func updateSound(sound: Sound) {
        AudioManager.shared.updateVolume(for: sound)
    }
}


// MARK: UITableViewDelegate
extension NoiseViewController: UITableViewDelegate {
    
}

// MARK: UITableViewDataSource
extension NoiseViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NoiseViewController.soundReuseIdentifier, for: indexPath)
        
        if let soundCell = cell as? SoundTableViewCell {
            soundCell.delegate = self
            soundCell.sound =  sounds[indexPath.row]
        }
        
        return cell
        
    }
    
}
// MARK: PeekingDelegate
extension NoiseViewController: SoundDelegate {
    
    func soundDidChange(_ sound: Sound, oldSound: Sound) {
        let soundRepository = Injection.soundRepository
        
        soundRepository.store(sound)
        updateSound(sound: sound)
    }
    
}

// MARK: PeekingDelegate
extension NoiseViewController: PeekingDelegate {
    
    func peekContext(_ context: PeekContext, viewControllerForPeekingAt location: CGPoint) -> UIViewController? {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "NoisePreviewViewController")
        if let viewController = viewController, let indexPath = tableView.indexPathForRow(at: location) {
            
            if let noisePreviewViewController = viewController as? NoisePreviewViewController {
                noisePreviewViewController.sound = sounds[indexPath.row]
            }
            
            if let cell = tableView.cellForRow(at: indexPath) {
                context.sourceRect = cell.frame
            }
            Injection.feedback.feedbackForPeek()
            return viewController
        }
        return nil
    }
    
    func peekContext(_ context: PeekContext, commit viewController: UIViewController) {
        Injection.feedback.feedbackForPeek()
//        show(viewController, sender: self)
    }
}
