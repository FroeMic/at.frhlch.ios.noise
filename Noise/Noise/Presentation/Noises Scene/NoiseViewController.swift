//
//  ViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit
import JustPeek
import Instructions

class NoiseViewController: UIViewController {
    
    static let soundReuseIdentifier = "SoundTableViewCell"
    
    private let pauseButtonImage = UIImage(named: "ic_pause_round")?.withRenderingMode(.alwaysTemplate)
    private let playButtonImage = UIImage(named: "ic_play_round")?.withRenderingMode(.alwaysTemplate)

    @IBOutlet var tableView: UITableView!
    @IBOutlet var playPauseButton: UIButton!
    
    var coachMarksController: CoachMarksController?
    var peekController: PeekController?
    
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
        
        peekController = PeekController()
        peekController?.register(viewController: self, forPeekingWithDelegate: self, sourceView: tableView)
        
        if Injection.settingsRepository.getShowInstructionMarks() {
            coachMarksController = CoachMarksController()
            coachMarksController?.overlay.color = UIColor.black.withAlphaComponent(0.4)
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
        
        sounds = Injection.soundRepository.getAll()
        tableView.reloadData()
        
        if Injection.settingsRepository.getAutoPlay() {
            playAudio()
        }
        
        if Injection.settingsRepository.getShowInstructionMarks() {
            coachMarksController?.start(on: self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        audioManager.deregister(delegate: self)
        coachMarksController?.stop(immediately: true)
        Injection.settingsRepository.setShowInstructionMarks(enabled: false)
        
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
        Injection.soundRepository.updateVolume(sound)
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
            coachViews.bodyView.hintLabel.text = "Tip: To preview any sound on it's own use Force Touch or a Long Press."
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
    
}
