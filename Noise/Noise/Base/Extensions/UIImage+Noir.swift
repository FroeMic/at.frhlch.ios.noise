//
//  UIIMage+Noir.swift
//  Noise
//
//  Created by Michael Fröhlich on 29.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

extension UIImage {
    
    var mono: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectMono") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
    
}
