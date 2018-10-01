//
//  ViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit
import Instructions

class NoiseViewController: UIViewController {
    
    static let soundReuseIdentifier = "SoundTableViewCell"
    
    private let pauseButtonImage = UIImage(named: "ic_pause_round")?.withRenderingMode(.alwaysTemplate)
    private let playButtonImage = UIImage(named: "ic_play_round")?.withRenderingMode(.alwaysTemplate)

    @IBOutlet var tableView: UITableView!
    @IBOutlet var playPauseButton: UIButton!
    
    var hasRegisteredForceTouchGesturerecognizer: Bool = false
    var coachMarksController: CoachMarksController?
    
    var sounds: [Sound] = []
    
    var audioManager: AudioManager {
        return AudioManager.shared
    }
    var isPlayingSounds: Bool {
        return audioManager.isMixtapeActive(id: "xxx-noise-all-sounds") && audioManager.state == .playing
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if Injection.settingsRepository.getShowInstructionMarks() {
            coachMarksController = CoachMarksController()
            coachMarksController?.overlay.color = UIColor.black.withAlphaComponent(0.4)
            coachMarksController?.overlay.allowTap = true
            coachMarksController?.delegate = self
            coachMarksController?.dataSource = self
        }
        
        playPauseButton?.tintColor = Injection.theme.tintColor
        updatePlayPauseButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        audioManager.register(delegate: self)
        updatePlayPauseButton()
        
        sounds = Injection.soundRepository.getAll().stableSorted(by: {$0.isOwned && !$1.isOwned})
        tableView.reloadData()
        
        if Injection.settingsRepository.getAutoPlay() {
            playAudio()
        }
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if Injection.settingsRepository.getShowInstructionMarks() {
                self.coachMarksController?.start(on: self)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        audioManager.deregister(delegate: self)
        coachMarksController?.stop(immediately: true)
        super.viewDidDisappear(animated)
    }
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        if isPlayingSounds {
            audioManager.pause()
        } else {
            playAudio()
        }
        updatePlayPauseButton()
        Injection.feedback.subtleFeedback()
    }
    
    private func updatePlayPauseButton() {
        if isPlayingSounds {
            playPauseButton.setImage(pauseButtonImage, for: .normal)
        } else {
            playPauseButton.setImage(playButtonImage, for: .normal)
        }
    }
    
    func playAudio() {
        let audioBundle = AudioBundle(id: "xxx-noise-all-sounds", title: "Ambient Sound Mix" , sounds: sounds)
        AudioManager.shared.activate(audio: audioBundle, hard: false )
    }
    
    func updateSound(sound: Sound) {
        if let index = sounds.firstIndex(of: sound) {
            sounds[index] = sound
        }
        if isPlayingSounds {
            AudioManager.shared.updateVolume(for: sound)
        }
    }
}


// MARK: UITableViewDelegate
extension NoiseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sound = sounds[indexPath.row]
        if !sound.isOwned {
            presentPreviewViewForSound(sound: sound)
        }
    }
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
            soundCell.sound = sounds[indexPath.row]
        }
        
        return cell
        
    }
    
}

// MARK: PeekingDelegate
extension NoiseViewController: SoundDelegate {
    
    func soundDidChange(_ sound: Sound, oldSound: Sound) {
        Injection.soundRepository.updateVolume(sound)
        updateSound(sound: sound)
    }
    
}

// MARK: AudioManagerDelegate
extension NoiseViewController: AudioManagerDelegate {
    func audioManager(_ audioManager: AudioManager, didChange state: AudioManagerState) {
        
        DispatchQueue.main.async {
            self.updatePlayPauseButton()
        }
    }
}

// MARK: CoachMarksControllerDataSource
extension NoiseViewController: CoachMarksControllerDataSource {
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        
        if index == 0 {
            coachViews.bodyView.hintLabel.text = "Tip: To preview any sound use Force Touch or a Long Press."
            coachViews.bodyView.nextLabel.text = "Ok"
        }

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        let poc = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        return coachMarksController.helper.makeCoachMark(for: poc)
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }
    
    
}


// MARK: CoachMarksControllerDelegate
extension NoiseViewController: CoachMarksControllerDelegate {
    func coachMarksController(_ coachMarksController: CoachMarksController, didHide coachMark: CoachMark, at index: Int) {
        if index == 1 {
            Injection.settingsRepository.setShowInstructionMarks(enabled: false)
        }
    }
}

extension NoiseViewController {
    
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
            let cell = tableView.cellForRow(at: indexPath) as? SoundTableViewCell,
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
