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
    static let buttonReuseIdentifier = "ButtonTableViewCell"
    static let placeholderReuseIdentifier = "PlaceholderTableViewCell"
    
    @IBOutlet var tableView: UITableView!
    
    var mixtapes: [Mixtape] {
        return Injection.mixtapeRepository.getAll().map { $0.1 }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    @objc func createNewMixtapeButtonPressed() {
        debugPrint("createNewMixtapeButtonPressed")
    }

}

// MARK: UITableViewDelegate
extension MixesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100.0
        }
        if indexPath.section == 1 {
            return tableView.frame.height - 90.0
        }
        if indexPath.section == 2 {
            return 69.0
        }
        return 0
    }
    
    
}

// MARK: UITableViewDataSource
extension MixesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return mixtapes.count
        }
        if section == 1 {
            return mixtapes.count == 0 ? 1 : 0
        }
        if section == 2 {
            return 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MixesViewController.soundReuseIdentifier, for: indexPath)
            
            return cell
        }
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MixesViewController.placeholderReuseIdentifier, for: indexPath)
            
            return cell
        }
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MixesViewController.buttonReuseIdentifier, for: indexPath)
            
            if let cell = cell as? ButtonTableViewCell {
                cell.addTarget(title: "Create Mixtape", target: self, action: #selector(MixesViewController.createNewMixtapeButtonPressed), for: .touchUpInside)
            }
                    
            return cell
        }
        
        return UITableViewCell()
        
    }
    
}
