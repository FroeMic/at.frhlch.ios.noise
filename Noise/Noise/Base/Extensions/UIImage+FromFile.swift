//
//  UIImage+FileManager.swift
//  Noise
//
//  Created by Michael Fröhlich on 21.09.18.
//  Copyright © 2018 Michael Fröhlich. All rights reserved.
//

import UIKit

extension UIImage {
    
    convenience init?(fromFile filename: String) {
        guard let filepath = FileManager.default.filepathFromDocumentsDirectoryOrBundle(filename: filename) else {
            return nil
        }
        self.init(contentsOfFile: filepath)
    }
    
    func saveImage(name: String) {
        let path = FileManager.default.getDocumentsURL()
        let url = URL(fileURLWithPath: path.path).appendingPathComponent(name)
        try? UIImagePNGRepresentation(self)?.write(to: url)
    }
    

}
