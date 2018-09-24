//
//  MixesViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 05.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class MixesViewController: UIViewController {
    
    static let mixesReuseIdentifier = "MixtapeTableViewCell"
    static let createMixtapeReuseIdentifier = "CreateMixtapeTableViewCell"
    
    static let editMixtapeSegueIdentifier = "showMixtapeDetail"
    
    @IBOutlet var tableView: UITableView!
    
    var mixtapes: [Mixtape] {
        return Injection.mixtapeRepository.getAll()
    }
    
    private var mixtapeRepository: MixtapeRepository {
        return Injection.mixtapeRepository
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show the Navigation Bar
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editMixtapeVC = segue.destination as? EditMixtapeViewController {
            editMixtapeVC.mixtape = sender as? Mixtape
        }
    }

}

// MARK: UITableViewDelegate
extension MixesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 120.0
        }
        if indexPath.section == 1 {
             return 120.0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: MixesViewController.editMixtapeSegueIdentifier, sender: nil)
        }
        if indexPath.section == 1 {
            performSegue(withIdentifier: MixesViewController.editMixtapeSegueIdentifier, sender: mixtapes[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 1 {
            return .delete
        }
        
        return .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section != 1 {
            return
        }
        
        if editingStyle == .delete {
            
            let mixtape = mixtapes[indexPath.row]
            
            // use async to avoid showing white background.
            DispatchQueue.main.async {
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            mixtapeRepository.remove(id: mixtape.id)
            
        }
    }
    
}

// MARK: UITableViewDataSource
extension MixesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        if section == 1 {
            return mixtapes.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MixesViewController.createMixtapeReuseIdentifier, for: indexPath)
            
            return cell
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MixesViewController.mixesReuseIdentifier, for: indexPath)
            
            if let cell = cell as? MixtapeTableViewCell {
                cell.mixtape = mixtapes[indexPath.row]
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
}
