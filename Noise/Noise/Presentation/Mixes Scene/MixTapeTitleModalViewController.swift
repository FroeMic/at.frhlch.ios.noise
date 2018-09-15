//
//  MixTapeTitleModalViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 15.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class MixTapeTitleModalViewController: UIViewController {
    
    var mixtape: Mixtape?
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textfield: UITextField!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var createButton: PrimaryButton!
    
    private var mixtapeName: String {
        return textfield?.text ?? ""
    }
    
    private var mixtapeRepository: MixtapeRepository {
        return Injection.mixtapeRepository
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        textfield.becomeFirstResponder()
        updateCreateButton()
    }
    
    private func updateCreateButton() {
        let theme = Injection.theme
        createButton.isEnabled = mixtapeName.count > 0
        createButton.backgroundColor = mixtapeName.count > 0 ? theme.tintColor : UIColor(displayP3Red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    private func createMixtape(title: String) {
        let mixtape = mixtapeRepository.create(title: title)
        debugPrint(mixtape)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
        if mixtapeName.count > 0 {
            createMixtape(title: mixtapeName)
        }
    }
    @IBAction func textFieldValueChanged(_ sender: Any) {
        updateCreateButton()
    }
    
    @IBAction func textFieldDidEndOnExit(_ sender: Any) {
        updateCreateButton()
        
        if mixtapeName.count > 0 {
            createMixtape(title: mixtapeName)
        }
    }
    
}


extension MixTapeTitleModalViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MixTapeTitleModalViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
