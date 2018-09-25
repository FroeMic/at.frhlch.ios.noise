//
//  SoundSelectionViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 17.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit
import JustPeek

class SoundSelectionViewController: UIViewController {
    
    static let soundSelectionCellReuseIdentifier = "SoundSelectionTableViewCell"
    
    var peekController: PeekController?
    var mixtape: Mixtape? {
        didSet {
            guard let mixtape = mixtape  else {
                selectedSounds = []
                return
            }
            selectedSounds = Array(mixtape.sounds)
        }
    }
    
    @IBOutlet var tableView: UITableView!
    private var sounds: [Sound] = []
    private var selectedSounds: [Sound] = []
    
    
    @IBOutlet var leftBarButtonItem: UIBarButtonItem!
    @IBOutlet var rightBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sounds = Injection.soundRepository.getAll()
        
        peekController = PeekController()
        peekController?.register(viewController: self, forPeekingWithDelegate: self, sourceView: tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let theme = Injection.theme
        
        // Show the Navigation Bar
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = theme.tintColor
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
            
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        saveMixtape()
        navigationController?.dismiss(animated: true, completion: nil)
    }

    
    private func saveMixtape() {
        guard var mixtape = mixtape else {
            return
        }
        
        mixtape.set(sounds: selectedSounds)
        Injection.mixtapeRepository.save(mixtape)
    }

}

// MARK: UITableViewDelegate
extension SoundSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let soundCell = cell as? SoundSelectionTableViewCell,
            let sound = soundCell.sound {
            
            if let index = selectedSounds.index(of: sound) {
                soundCell.sound = selectedSounds[index]
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else{
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath),
            let soundCell = cell as? SoundSelectionTableViewCell,
            let sound = soundCell.sound {
            
            selectedSounds.append(sound)
            
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath),
            let soundCell = cell as? SoundSelectionTableViewCell,
            let sound = soundCell.sound,
            let index = selectedSounds.index(of: sound){
            
            selectedSounds.remove(at: index)
            
        }
    }
    
    
}

// MARK: UITableViewDataSource
extension SoundSelectionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SoundSelectionViewController.soundSelectionCellReuseIdentifier, for: indexPath)
        
        if let soundCell = cell as? SoundSelectionTableViewCell {
            soundCell.sound = sounds[indexPath.row]
        }

        return cell
    }
}


// MARK: PeekingDelegate
extension SoundSelectionViewController: PeekingDelegate {
    
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
    }
}
