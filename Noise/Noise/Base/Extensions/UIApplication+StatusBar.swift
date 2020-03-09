//
//  UIApplication+StatusBar.swift
//  Noise
//
//  Created by Michael Fröhlich on 24.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

extension UIApplication {
    var statusBarView: UIView? {
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
             UIApplication.shared.keyWindow?.addSubview(statusBar)
            return statusBar
        } else if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
         } else {
            return nil
         }
    }
}

