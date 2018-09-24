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
    
    @IBOutlet var acknowledgmentsTableViewCell: UITableViewCell!
    @IBOutlet var acknowledgmentsLabel: UILabel!
    @IBOutlet var acknowledgmentsChevronImageView: UIImageView!
    
    private var headerView: UIView?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        setupHeaderView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarView?.backgroundColor = .white
        
        UIView.animate(withDuration: 0.2, animations: {
            self.headerView?.alpha = 1.0
        })
        
        applyTheme()
        tableView.reloadData()
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
        
        acknowledgmentsTableViewCell.selectionStyle = .none
        acknowledgmentsTableViewCell.backgroundColor = .white
        acknowledgmentsLabel.textColor = theme.textColor
        
        if let image = acknowledgmentsChevronImageView.image {
            let coloredImage = image.withRenderingMode(.alwaysTemplate)
            acknowledgmentsChevronImageView.image = coloredImage
            acknowledgmentsChevronImageView.tintColor = theme.textColor
        }
        
    }
    
}

extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let selectedTheme = Injection.theme
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor =  selectedTheme.textColor.withAlphaComponent(0.8)
            headerView.backgroundColor = .white
            headerView.tintColor = .white
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let selectedTheme = Injection.theme
        if let footerView = view as? UITableViewHeaderFooterView {
            footerView.textLabel?.textColor = selectedTheme.textColor.withAlphaComponent(0.8)
            footerView.backgroundColor = .white
            footerView.tintColor = .white
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
            // Todo: Open App Store rating page
                ()
            case 1:
            // Todo: Show about About ViewController
                ()
            case 2:
                performSegue(withIdentifier: SettingsViewController.showAcknowledgementSegueIdentifier, sender: nil)
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


