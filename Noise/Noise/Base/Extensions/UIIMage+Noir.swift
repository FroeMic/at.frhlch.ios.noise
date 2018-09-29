//
//  UIIMage+Noir.swift
//  Noise
//
//  Created by Michael Fröhlich on 29.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

extension UIImage {
    
    func noir() -> UIImage {
        let context = CIContext(options: nil)
        
        let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
        currentFilter!.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        let output = currentFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!, scale: scale, orientation: imageOrientation)
        return processedImage
    }

}
