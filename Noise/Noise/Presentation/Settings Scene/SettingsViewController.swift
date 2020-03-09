//
//  SettingViewController.swift
//  ping
//
//  Created by Michael Fröhlich on 04.08.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    static let showAcknowledgementSegueIdentifier = "showAcknowledgementScene"
    static let showAboutSegueIdentifier = "showAboutScene"
    static let showInDataPrivacySegueIdentifier = "showDataPrivacyScene"
    static let showInAppPurchaseIdentifier = "showInAppPurchasesScene"
    
    @IBOutlet var keepDisplayActiveTableViewCell: UITableViewCell!
    @IBOutlet var keepDisplayActiveLabel: UILabel!
    @IBOutlet var keepDisplayActiveSwitch: UISwitch!
    
    @IBOutlet var playAutomticallyTableViewCell: UITableViewCell!
    @IBOutlet var playAutomaticallyLabel: UILabel!
    @IBOutlet var playAutomaticallySwitch: UISwitch!
    
    @IBOutlet var playInBackgroundLabel: UILabel!
    @IBOutlet var playInBackgroundTableViewCell: UITableViewCell!
    @IBOutlet var playInBackgroundSwitch: UISwitch!
    
    @IBOutlet var nightModeLabel: UILabel!
    @IBOutlet var nightModeTableViewCell: UITableViewCell!
    @IBOutlet var NightModeSwitch: UISwitch!
    
    @IBOutlet var inAppPurchasesTableViewCell: UITableViewCell!
    @IBOutlet var inAppPurchasesLabel: UILabel!
    @IBOutlet var inAppPurchasesChevronImageView: UIImageView!
    
    @IBOutlet var rateNoiseCell: UITableViewCell!
    @IBOutlet var rateNoiseLabel: UILabel!
    
    @IBOutlet var showOnboardingCell: UITableViewCell!
    @IBOutlet var showOnboardingLabel: UILabel!
    
    @IBOutlet var aboutTableViewCell: UITableViewCell!
    @IBOutlet var aboutLabel: UIView!
    @IBOutlet var aboutChevronImageView: UIImageView!
    
    @IBOutlet var acknowledgmentsTableViewCell: UITableViewCell!
    @IBOutlet var acknowledgmentsLabel: UILabel!
    @IBOutlet var acknowledgmentsChevronImageView: UIImageView!
    
    @IBOutlet var dataPrivacyCell: UITableViewCell!
    @IBOutlet var dataPrivacyLabel: UILabel!
    @IBOutlet var dataPrivacyChevronImageview: UIImageView!
    
    private var headerView: UIView?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        setupHeaderView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        keepDisplayActiveSwitch.isOn = Injection.settingsRepository.getKeepDisplayActive()
        playAutomaticallySwitch.isOn = Injection.settingsRepository.getAutoPlay()
        playInBackgroundSwitch.isOn = Injection.settingsRepository.getBackgroundPlay()
        
        UIApplication.shared.statusBarView?.backgroundColor = .white
        
        UIView.animate(withDuration: 0.2, animations: {
            self.headerView?.alpha = 1.0
        })
        
        applyTheme()
        
        playInBackgroundSwitch.isEnabled = StoreKitManager.shared.hasPlayInBackground()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Note: this is a bit of a hack. Tabbar changes do not trigger this method,
        // thus only if we are within this tab, the alpha will be set to 0.
        //
        // If we did this in the viewWillAppear method, there would be a visual "glitch"
        // whenever the user cycles back to settings using the tab bar
        
        UIView.animate(withDuration: 0.2, animations: {
            self.headerView?.alpha = 0.0
        })
    }
    
    private func setupHeaderView() {
        
        guard let navigationBar = navigationController?.navigationBar else {
            return
        }

        let titleView = UIView(frame: navigationBar.bounds)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = .white
        navigationBar.addSubview(titleView)

        let titleViewConstraints = [
            NSLayoutConstraint(item: titleView, attribute: .width, relatedBy: .equal, toItem: navigationBar, attribute: .width, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: titleView, attribute: .height, relatedBy: .equal, toItem: navigationBar, attribute: .height, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: titleView, attribute: .left, relatedBy: .equal, toItem: navigationBar, attribute: .left, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: titleView, attribute: .top, relatedBy: .equal, toItem: navigationBar, attribute: .top, multiplier: 1.0, constant: 0),
            ]
        navigationBar.addConstraints(titleViewConstraints)

        let titleLabel = UILabel(frame: CGRect(x: 16, y: 30, width: 200, height: 33))
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Settings"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28.0)

        let noiseIcon = UIImageView(frame: CGRect(x: 300, y: 30, width: 35, height: 35))
        noiseIcon.translatesAutoresizingMaskIntoConstraints = false
        noiseIcon.contentMode = .scaleAspectFit
        noiseIcon.image = UIImage(named: "ic_noise")

        titleView.addSubview(titleLabel)
        titleView.addSubview(noiseIcon)

        let noiseIconConstraints = [
            NSLayoutConstraint(item: noiseIcon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 35.0),
            NSLayoutConstraint(item: noiseIcon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 35.0)
        ]

        noiseIcon.addConstraints(noiseIconConstraints)

        let constraints = [
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: titleView, attribute: .leading, multiplier: 1.0, constant: 16),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: noiseIcon, attribute: .leading, multiplier: 1.0, constant: 16),
            NSLayoutConstraint(item: noiseIcon, attribute: .trailing, relatedBy: .equal, toItem: titleView, attribute: .trailing, multiplier: 1.0, constant: -16),
            NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: titleView, attribute: .centerY, multiplier: 1.0, constant: 5),
            NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: noiseIcon, attribute: .centerY, multiplier: 1.0, constant: 0),
        ]

        titleView.addConstraints(constraints)
        
        headerView = titleView

    }

    func applyTheme() {
        let theme = Injection.theme
        
        // Show the Navigation Bar
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = theme.tintColor
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        keepDisplayActiveTableViewCell.selectionStyle = .none
        keepDisplayActiveTableViewCell.backgroundColor = .white
        keepDisplayActiveLabel.textColor = theme.textColor
        
        playAutomticallyTableViewCell.selectionStyle = .none
        playAutomticallyTableViewCell.backgroundColor = .white
        playAutomaticallyLabel.textColor = theme.textColor

        playInBackgroundTableViewCell.selectionStyle = .none
        playInBackgroundTableViewCell.backgroundColor = .white
        playInBackgroundLabel.textColor = theme.textColor
        
        inAppPurchasesTableViewCell.selectionStyle = .none
        inAppPurchasesTableViewCell.backgroundColor = .white
        inAppPurchasesLabel.textColor = theme.textColor
        
        if let image = inAppPurchasesChevronImageView.image {
            let coloredImage = image.withRenderingMode(.alwaysTemplate)
            inAppPurchasesChevronImageView.image = coloredImage
            inAppPurchasesChevronImageView.tintColor = theme.textColor
        }
        
        rateNoiseCell.selectionStyle = .none
        rateNoiseCell.backgroundColor = .white
        rateNoiseLabel.textColor = theme.textColor

        showOnboardingCell.selectionStyle = .none
        showOnboardingCell.backgroundColor = .white
        showOnboardingLabel.textColor = theme.textColor
        
        aboutTableViewCell.selectionStyle = .none
        aboutTableViewCell.backgroundColor = .white
        acknowledgmentsLabel.textColor = theme.textColor
        
        if let image = aboutChevronImageView.image {
            let coloredImage = image.withRenderingMode(.alwaysTemplate)
            aboutChevronImageView.image = coloredImage
            aboutChevronImageView.tintColor = theme.textColor
        }
        
        acknowledgmentsTableViewCell.selectionStyle = .none
        acknowledgmentsTableViewCell.backgroundColor = .white
        acknowledgmentsLabel.textColor = theme.textColor
        
        if let image = acknowledgmentsChevronImageView.image {
            let coloredImage = image.withRenderingMode(.alwaysTemplate)
            acknowledgmentsChevronImageView.image = coloredImage
            acknowledgmentsChevronImageView.tintColor = theme.textColor
        }
        
        dataPrivacyCell.selectionStyle = .none
        dataPrivacyCell.backgroundColor = .white
        dataPrivacyLabel.textColor = theme.textColor
        
        if let image = dataPrivacyChevronImageview.image {
            let coloredImage = image.withRenderingMode(.alwaysTemplate)
            dataPrivacyChevronImageview.image = coloredImage
            dataPrivacyChevronImageview.tintColor = theme.textColor
        }
    }
    
    @IBAction func keepDisplayActiveSwitchValueChanged(_ sender: Any) {
        Injection.settingsRepository.setKeepDisplayActive(enabled: keepDisplayActiveSwitch.isOn)
        UIApplication.shared.isIdleTimerDisabled = keepDisplayActiveSwitch.isOn
    }
    
    
    @IBAction func playAutomaticallySwitchValueChanged(_ sender: Any) {
        Injection.settingsRepository.setAutoPlay(enabled: playAutomaticallySwitch.isOn)
    }
    
    @IBAction func playInBackgroundSwitchValueChanged(_ sender: Any) {
        Injection.settingsRepository.setBackgroundPlay(enabled: playInBackgroundSwitch.isOn)
    }
    
    @IBAction func nightModeSwitchValueChanged(_ sender: Any) {
        if NightModeSwitch.isOn {
            Injection.settingsRepository.setSelectedTheme(key: DarkTheme.key)
        } else {
            Injection.settingsRepository.setSelectedTheme(key: DefaultTheme.key)
        }
    }
    
}

extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let selectedTheme = Injection.theme
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor =  selectedTheme.textColor.withAlphaComponent(0.8)
            headerView.tintColor = .white
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let selectedTheme = Injection.theme
        if let footerView = view as? UITableViewHeaderFooterView {
            footerView.textLabel?.textColor = selectedTheme.textColor.withAlphaComponent(0.8)
            footerView.tintColor = .white
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.section == 1 {
            
            if indexPath.row == 2 {
                if StoreKitManager.shared.hasPlayInBackground() {
                    return
                }

                let alertController = UIAlertController(title: nil, message: "Play in Backround is an additional feature. Do you want to buy it?", preferredStyle: .alert)
                alertController.view.tintColor = Injection.theme.tintColor
                
                
                let showStoreVC = UIAlertAction(title: "Buy", style: .default, handler: { (action) -> Void in
                    self.performSegue(withIdentifier: SettingsViewController.showInAppPurchaseIdentifier, sender: nil)
                })

                let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: { (_) -> Void in })

                alertController.addAction(cancelButton)
                alertController.addAction(showStoreVC)
                
                self.present(alertController, animated: true)
            }
            
            if indexPath.row == 3 {
                performSegue(withIdentifier: SettingsViewController.showInAppPurchaseIdentifier, sender: nil)
            }
        }
        
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                RatingManager.triggerRatingView()
            case 1:
                let controller = OnboardingPresentationController(dismissOnCompletion: true)
                self.present(controller, animated: true)
            case 2:
                performSegue(withIdentifier: SettingsViewController.showAboutSegueIdentifier, sender: nil)
            case 3:
                performSegue(withIdentifier: SettingsViewController.showAcknowledgementSegueIdentifier, sender: nil)
            case 4:
                performSegue(withIdentifier: SettingsViewController.showInDataPrivacySegueIdentifier, sender: nil)
            default:
                return
                // do nothing
            }
        }
        
        if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id1397401806") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            case 1:
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id1397237592") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            case 2:
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id1396053383") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }            default:
                return
                // do nothing
            }
        }


    }
    
}


