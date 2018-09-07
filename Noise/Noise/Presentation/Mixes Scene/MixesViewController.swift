//
//  MixesViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 05.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import Foundation

import UIKit

class MixesViewController: UIViewController {
    
    static let soundReuseIdentifier = "SoundTableViewCell"
    
    @IBOutlet var tableView: UITableView!
    
    var mixtapes: [Mixtape] {
        return Injection.mixtapeRepository.getAll().map { $0.1 }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }

}

// MARK: UITableViewDelegate
extension MixesViewController: UITableViewDelegate {
    
    
}

// MARK: UITableViewDataSource
extension MixesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mixtapes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NoiseViewController.soundReuseIdentifier, for: indexPath)
        
        return cell
        
    }
    
}
