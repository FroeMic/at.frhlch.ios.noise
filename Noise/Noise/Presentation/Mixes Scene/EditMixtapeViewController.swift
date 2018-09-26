//
//  EditMixtapeViewControlle.swift
//  Noise
//
//  Created by Michael Fröhlich on 17.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit
import YPImagePicker
import JustPeek

class EditMixtapeViewController: UIViewController {
    
    static let soundReuseIdentifier = "SoundTableViewCell"
    static let addSoundReuseIdentifier = "AddSoundTableViewCell"
    
    static let presentSelectSoundsVCSegueIdentifier = "presentSelectSoundVC"
    
    var mixtape: Mixtape?
    var peekController: PeekController?

    var audioManager: AudioManager {
        return AudioManager.shared
    }
    var isPlayingCurrentMixtape: Bool {
        guard let mixtape = mixtape else {
            return false
        }
        return audioManager.isMixtapeActive(mixtape: mixtape) && audioManager.state == .playing
    }
    
    private var sounds: [Sound]  {
        return mixtape?.sounds ?? []
    }
    
    private var pickerConfig: YPImagePickerConfiguration?
    private var picker: YPImagePicker?
    private var alertController: UIAlertController?
    private let pauseButtonImage = UIImage(named: "ic_pause_round")?.withRenderingMode(.alwaysTemplate)
    private let playButtonImage = UIImage(named: "ic_play_round")?.withRenderingMode(.alwaysTemplate)
    
    private var mixtapeRepository: MixtapeRepository {
        return Injection.mixtapeRepository
    }
    
    @IBOutlet var titleTextfield: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var imageView: RoundedImageView!
    @IBOutlet var triggerPickerView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var playPauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Mixtape"
        
        hideKeyboardWhenTappedAround()
        
        if mixtape == nil {
            title = "Create Mixtape"
            self.mixtape = mixtapeRepository.create(title: "New Mixtape")
            titleTextfield.becomeFirstResponder()
        }
        
        peekController = PeekController()
        peekController?.register(viewController: self, forPeekingWithDelegate: self, sourceView: tableView)
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(EditMixtapeViewController.pickerViewPressed))
        triggerPickerView.addGestureRecognizer(gr)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let mixtape = mixtape {
            self.mixtape = Injection.mixtapeRepository.get(id: mixtape.id)
        }
        
        tableView.reloadData()
        
        let theme = Injection.theme
        
        // Show the Navigation Bar
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = theme.tintColor
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        playPauseButton.tintColor = theme.tintColor
        
        updateView()
        
        audioManager.register(delegate: self)
        
        if Injection.settingsRepository.getAutoPlay() {
            playAudio()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveMixtape()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        audioManager.deregister(delegate: self)
        super.viewDidDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        saveMixtape()
        if let navigationVC = segue.destination as? UINavigationController,
            let soundSelectionVC = navigationVC.topViewController as? SoundSelectionViewController {
            soundSelectionVC.mixtape = mixtape
        }
    }
    
    @IBAction func playPauseButtonPressed(_ sender: UIButton) {
        
        if isPlayingCurrentMixtape {
            audioManager.pause()
        } else {
            playAudio()
        }
        updatePlayPauseButton()
        Injection.feedback.subtleFeedback()
    }
    
    private func updatePlayPauseButton() {
        if isPlayingCurrentMixtape {
            playPauseButton.setImage(pauseButtonImage, for: .normal)
        } else {
            playPauseButton.setImage(playButtonImage, for: .normal)
        }
    }
    
    @objc func pickerViewPressed() {
        if imageView.image == nil {
            presentPicker()
        } else {
            presentAlertController()
        }
    }
    
    private func updateView() {
        guard let mixtape = mixtape else {
            return
        }
        
        titleTextfield.text = mixtape.title
        descriptionTextView.text = mixtape.detailDescription == nil ? "..." : mixtape.detailDescription
        imageView.image = mixtape.image
        playPauseButton?.isEnabled = sounds.count > 0
        updatePlayPauseButton()
    }
    
    private func presentPicker() {
        initPicker()
        guard let picker = self.picker else {
            return
        }
        
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                //                print(photo.fromCamera) // Image source (camera or library)
                //                print(photo.image) // Final image selected by the user
                //                print(photo.originalImage) // original image selected by the user, unfiltered
                //                print(photo.modifiedImage) // Transformed image, can be nil
                //                print(photo.exifMeta) // Print exif meta data of original image.
                
                self.mixtape?.image = photo.image
                self.saveMixtape()
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    private func presentAlertController() {
        initAlertController()
        guard let alertController = self.alertController else {
            return
        }
        present(alertController, animated: true)
    }
    
    private func initPicker() {
        if self.pickerConfig == nil {
            var config = YPImagePickerConfiguration()
            config.library.mediaType = .photo
            config.library.onlySquare  = true
            config.onlySquareImagesFromCamera = true
            config.targetImageSize = .cappedTo(size: 500)
            config.usesFrontCamera = true
            config.showsFilters = true
            config.shouldSaveNewPicturesToAlbum = false
            config.screens = [.library]
            config.startOnScreen = .library
            config.video.recordingTimeLimit = 10
            config.video.libraryTimeLimit = 20
            config.showsCrop = .rectangle(ratio: (1/1))
            config.library.maxNumberOfItems = 1
            
            self.pickerConfig = config
        }
        
        self.picker = YPImagePicker(configuration: self.pickerConfig!)
    }
    
    private func initAlertController() {
        if self.alertController != nil {
            return
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tintColor = Injection.theme.tintColor
        
        let pickImage = UIAlertAction(title: "Choose picture", style: .default, handler: { (action) -> Void in
            self.presentPicker()
        })
        
        let removeImage = UIAlertAction(title: "Remove picture", style: .default, handler: { (action) -> Void in
            self.mixtape?.image = nil
            self.updateView()
            self.saveMixtape()
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) -> Void in })
        
        alertController.addAction(pickImage)
        alertController.addAction(removeImage)
        alertController.addAction(cancelButton)
        
        self.alertController = alertController
    }
    
    private func saveMixtape() {
        
        if let title = titleTextfield.text  {
            mixtape?.title = title
        }
        
        if let description = descriptionTextView.text {
             mixtape?.detailDescription = description
        }
        
        if let image = imageView.image {
             mixtape?.image = image
        }
        
        guard let mixtape = mixtape else {
            return 
        }
        
        Injection.mixtapeRepository.save(mixtape)
        
        if isPlayingCurrentMixtape {
            updateNowPlayingInformation()
        }
    }
    
    func updateSound(sound: Sound) {
        audioManager.updateVolume(for: sound)
    }
    
    func playAudio() {
        guard let audioBundle = makeAudioBundle() else {
            return
        }
        if isPlayingCurrentMixtape {
            audioManager.activate(audio: audioBundle, hard: false)
        } else {
            audioManager.activate(audio: audioBundle, hard: true)
        }
    }
    
    func updateNowPlayingInformation() {
        guard let audioBundle = makeAudioBundle() else {
            audioManager.stop()
            return
        }
        audioManager.activate(audio: audioBundle, hard: false)
    }
    
    private func makeAudioBundle() -> AudioBundle? {
        guard let mixtape = mixtape else {
            return nil
        }
        if sounds.count == 0 {
            return nil
        }
        var audioBundle = AudioBundle(mixtape: mixtape)
        audioBundle.sounds = self.sounds
        return audioBundle
    }
    
}

extension EditMixtapeViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditMixtapeViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}



// MARK: UITableViewDelegate
extension EditMixtapeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60.0
        }
        if indexPath.section == 1 {
            return 90
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: EditMixtapeViewController.presentSelectSoundsVCSegueIdentifier, sender: nil)
        }

    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let sound = sounds[indexPath.row]
            mixtape?.remove(sound: sound)
            updateNowPlayingInformation()

            // use async to avoid showing white background.
            DispatchQueue.main.async {
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
}

// MARK: UITableViewDataSource
extension EditMixtapeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        if section == 1 {
            return sounds.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: EditMixtapeViewController.addSoundReuseIdentifier, for: indexPath)
            
            return cell
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: EditMixtapeViewController.soundReuseIdentifier, for: indexPath)

            if let cell = cell as? SoundTableViewCell {
                cell.sound = sounds[indexPath.row]
                cell.delegate = self
            }

            return cell
        }
        return UITableViewCell()
    }
    
}


// MARK: SoundDelegate
extension EditMixtapeViewController: SoundDelegate {
    
    func soundDidChange(_ sound: Sound, oldSound: Sound) {
                
        guard let _ = sounds.index(of: sound) else {
            return
        }

        mixtape?.update(sound: sound)
        updateSound(sound: sound)
    }
    
}

// MARK: AudioManagerDelegate
extension EditMixtapeViewController: AudioManagerDelegate {
    func audioManager(_ audioManager: AudioManager, didChange state: AudioManagerState) {
        
        DispatchQueue.main.async {
            self.updatePlayPauseButton()
        }
    }
}


// MARK: PeekingDelegate
extension EditMixtapeViewController: PeekingDelegate {
    
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
