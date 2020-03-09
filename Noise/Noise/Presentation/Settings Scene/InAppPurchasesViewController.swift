//
//  InAppPurchasesViewController.swift
//  Noise
//
//  Created by Michael Fröhlich on 29.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

class InAppPurchasesViewController: UIViewController {
    
    private static let inAppPurchaseTableViewCellReuseIdentifier = "InAppPurchaseTableViewCell"
    private static let restorePurchasesTableViewCellReuseIdentifier = "RestorePurchasesTableViewCell"
    
    private var otherInAppPurchases: [InAppPurchase] = []
    private var soundInAppPurchases: [InAppPurchase] = []
    
    @IBOutlet var connectionView: UIView!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "In App Purchases"
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        applyTheme()
        refreshTableView()
    }
    
    func applyTheme() {
        let theme = Injection.theme
        
        connectionView.backgroundColor = theme.backgroundColor
        view.backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        
        // Show the Navigation Bar
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = theme.tintColor
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()

    }
    
    private func refreshTableView() {
        otherInAppPurchases = [
            InAppPurchase(id: "at.frhlch.ios.noise.premium", title: "Noise Premium", priceString: StoreKitManager.shared.premiumPrice),
            InAppPurchase(id: "at.frhlch.ios.noise.dark_mode", title: "Dark Mode", priceString: StoreKitManager.shared.darkModePrice),
            InAppPurchase(id: "at.frhlch.ios.noise.play_in_background", title: "Play In Background", priceString: StoreKitManager.shared.backgroundPlayPrice),
            
        ]
        soundInAppPurchases = Injection.soundRepository.getAll().compactMap { InAppPurchase(sound: $0) }
        
        tableView.reloadData()
    }
    
    private func showConntectionView() {
        connectionView.isHidden = false
    }
    
    private func hideConntectionView() {
        connectionView.isHidden = true
    }
    
    private func inAppPurchaseForIndexPath(indexPath: IndexPath) -> InAppPurchase? {
        if indexPath.section == 0 {
            return otherInAppPurchases[indexPath.row]
        } else if indexPath.section == 1 {
            return soundInAppPurchases[indexPath.row]
        } else if indexPath.section == 2 {
            return nil
        }
        return nil
    }
    
    private func cellForIndexPath(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 || indexPath.section == 1 {
            return tableView.dequeueReusableCell(withIdentifier: InAppPurchasesViewController.inAppPurchaseTableViewCellReuseIdentifier, for: indexPath)
        }
        if indexPath.section == 2 {
            return tableView.dequeueReusableCell(withIdentifier: InAppPurchasesViewController.restorePurchasesTableViewCellReuseIdentifier, for: indexPath)
        }
        return UITableViewCell()
    }

}

// MARK: UITableViewDelegate
extension InAppPurchasesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.section < 2 else {
            showConntectionView()
            StoreKitManager.shared.restorePurchases() { (success) in
                self.refreshTableView()
                self.hideConntectionView()
            }
            return
        }
        
        
        guard let inAppPurchase = inAppPurchaseForIndexPath(indexPath: indexPath) else {
            return
        }
        
        guard !inAppPurchase.isOwned else {
            return
        }
        
        showConntectionView()
        StoreKitManager.shared.purchaseProduct(id: inAppPurchase.id) { (success) in
            self.refreshTableView()
            self.hideConntectionView()
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let theme = Injection.theme
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor =  theme.textColor.withAlphaComponent(0.8)
            headerView.tintColor = theme.backgroundColor
        }
    }

}

// MARK: UITableViewDataSource
extension InAppPurchasesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Other Purchases"
        }
        if section == 1 {
            return "Sounds"
        }
        if section == 2 {
            return " "
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return otherInAppPurchases.count
        }
        if section == 1 {
            return soundInAppPurchases.count
        }
        if section == 2 {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cellForIndexPath(tableView: tableView, indexPath: indexPath)
        
        guard let inAppPurchaseCell = cell as? InAppPurchaseTableViewCell else {
            return cell
        }
        
        guard let inAppPurchase = inAppPurchaseForIndexPath(indexPath: indexPath) else {
            return cell
        }
        
        inAppPurchaseCell.inAppPurchase = inAppPurchase
        
        return inAppPurchaseCell
    }
    
}


