//
//  ViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class NoiseViewController: UIViewController {
    
    static let soundReuseIdentifier = "SoundTableViewCell"

    @IBOutlet var tableView: UITableView!
    
    var sounds: [Sound] {
        return Injection.soundRepository.getAll().map { $0.1 }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AudioManager.shared.activate(sounds: sounds, title: "Noise Ambient Sounds")

        tableView.delegate = self
        tableView.dataSource = self
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
            soundCell.sound =  sounds[indexPath.row]
        }
        
        return cell
        
    }
    
}
