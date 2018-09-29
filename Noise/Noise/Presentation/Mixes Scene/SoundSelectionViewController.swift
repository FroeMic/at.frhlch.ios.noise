//
//  SoundSelectionViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 17.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class SoundSelectionViewController: UIViewController {
    
    static let soundSelectionCellReuseIdentifier = "SoundSelectionTableViewCell"
    var hasRegisteredForceTouchGesturerecognizer: Bool = false

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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if hasRegisteredForceTouchGesturerecognizer {
            return
        }

        let canHandleForceTouch = tableView.traitCollection.forceTouchCapability == .available
        if canHandleForceTouch {
            let recognizer = ForceTouchGestureRecognizer(target: self, action: #selector(forceTouchOnTableView))
            tableView.addGestureRecognizer(recognizer)
            hasRegisteredForceTouchGesturerecognizer = true
        } else {
            let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnTableView))
            recognizer.minimumPressDuration = 1.0
            tableView.addGestureRecognizer(recognizer)
            hasRegisteredForceTouchGesturerecognizer = true
        }
        
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


extension SoundSelectionViewController {
    
    func presentPreviewViewForSound(sound: Sound) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let npVC = storyboard.instantiateViewController(withIdentifier: "NoisePreviewViewController") as? NoisePreviewViewController else {
            return
        }
        
        let oldDefinePresentationContext = definesPresentationContext
        definesPresentationContext = true
        
        // presented view controller
        npVC.modalPresentationStyle = .overFullScreen
        npVC.modalTransitionStyle = .crossDissolve
        
        npVC.sound = sound
        
        present(npVC, animated: true)
        Injection.feedback.feedbackForPeek()
        definesPresentationContext = oldDefinePresentationContext
        
    }
    
    func selectedTableViewAtPoint(point: CGPoint) {
        guard let indexPath = tableView.indexPathForRow(at: point),
            let cell = tableView.cellForRow(at: indexPath) as? SoundSelectionTableViewCell,
            let sound = cell.sound else {
                return
        }
        
        presentPreviewViewForSound(sound: sound)
    }
    
    @IBAction func forceTouchOnTableView(_ recognizer: ForceTouchGestureRecognizer) {
        guard recognizer.state == .began else {
            return
        }
        
        let point = recognizer.location(in: tableView)
        selectedTableViewAtPoint(point: point)
    }
    
    @IBAction func longPressOnTableView(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began else {
            return
        }
        
        let point = recognizer.location(in: tableView)
        selectedTableViewAtPoint(point: point)
    }
    
}

