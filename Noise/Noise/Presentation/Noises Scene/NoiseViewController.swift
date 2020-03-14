//
//  ViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 28.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit
import Instructions

class NoiseViewController: UIViewController, InterfaceThemeSubscriber {
    
    static let soundReuseIdentifier = "SoundTableViewCell"
    
    private var lastAppearance: Date?
    private let pauseButtonImage = UIImage(named: "ic_pause_round")?.withRenderingMode(.alwaysTemplate)
    private let playButtonImage = UIImage(named: "ic_play_round")?.withRenderingMode(.alwaysTemplate)

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!
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
        Injection.themePublisher.subscribeToThemeUpdates(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        audioManager.register(delegate: self)
        updatePlayPauseButton()
        
        //lastAppearance
        let freshSounds = Injection.soundRepository.getAll()
        var needsUpdate = false
    
        if let lastAppearance = self.lastAppearance  {
            needsUpdate =  lastAppearance < StoreKitManager.shared.lastBuyingDecision
        }
        
        if freshSounds.count != sounds.count {
            needsUpdate = true
        }
        
        if needsUpdate {
            sounds = freshSounds.stableSorted(by: {$0.isOwned && !$1.isOwned})
            tableView.reloadData()
        }
        
        lastAppearance = Date()
        applyTheme()
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
        
        prepareAudio()
        
        if Injection.settingsRepository.getAutoPlay() {
            playAudio()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        audioManager.deregister(delegate: self)
        coachMarksController?.stop(immediately: true)
        super.viewDidDisappear(animated)
    }
    
    func applyTheme() {
        let theme = Injection.theme
        view.backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        tableView.backgroundView?.backgroundColor = theme.backgroundColor
        
        titleLabel.textColor = theme.textColor
        subtitleLabel.textColor = theme.textColor
        logoImageView.tintColor = theme.textColor
        logoImageView.image =  logoImageView.image?.withRenderingMode(.alwaysTemplate)
        playPauseButton.tintColor = theme.tintColor
        
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: theme.textColor]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: theme.textColor]
            navBarAppearance.backgroundColor = theme.backgroundColor
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        } else {
            // Fallback on earlier versions
            UIApplication.shared.statusBarStyle = theme.statusBarStyle
        }
        
        navigationController?.navigationBar.backgroundColor = theme.backgroundColor
        navigationController?.navigationBar.barStyle = theme.barStyle
        navigationController?.navigationBar.tintColor = theme.textColor
        navigationController?.navigationBar.barTintColor = theme.backgroundColor
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
    
    private func makeAudioBundle() -> AudioBundle? {
        return AudioBundle(id: "xxx-noise-all-sounds", title: "Ambient Sound Mix" , sounds: sounds)
    }
    
    func prepareAudio() {
        guard let audioBundle = makeAudioBundle() else {
            return
        }
        AudioManager.shared.prepareForActivation(audio: audioBundle)
    }
    
    func playAudio() {
        guard let audioBundle = makeAudioBundle() else {
            return
        }
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sound = sounds[indexPath.row]
        if !sound.isOwned {
            presentPreviewViewForSound(sound: sound)
        }
        // automatically set the sound volume and play
        if sound.isOwned {
            if let soundTableViewCell = tableView.cellForRow(at: indexPath) as? SoundTableViewCell {
                let currentVolume = soundTableViewCell.slider?.value ?? 0
                let newVolume: Float = currentVolume == 0 ? 0.33 : 0.0
                soundTableViewCell.slider?.value = newVolume
                soundTableViewCell.sliderValueDidChange() // trigger manual update ... somewhat of a hack
                
                if !isPlayingSounds {
                    playAudio()
                    updatePlayPauseButton()
                }
            }
        }
    }
}

// MARK: UITableViewDataSource
extension NoiseViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return tableView.dequeueReusableCell(withIdentifier: NoiseViewController.soundReuseIdentifier, for: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let soundCell = cell as? SoundTableViewCell {
            soundCell.delegate = self
            soundCell.sound = sounds[indexPath.row]
        }
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
        npVC.modalPresentationStyle = .fullScreen
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
