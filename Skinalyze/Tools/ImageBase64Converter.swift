//
//  ImageBase64Converter.swift
//  Skinalyze
//
//  Created by Ali Haidar on 10/14/24.
//


import Foundation
import UIKit

extension UIImage {
    //    func toBase64String() -> String? {
    //        guard let imageData = self.pngData() else {
    //            return nil
    //        }
    //        return imageData.base64EncodedString()
    //    }
    
    var base64: String? {
        self.jpegData(compressionQuality: 1)?.base64EncodedString()
    }
}

extension String {
//    var imageFromBase64: UIImage? {
//        guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
//            return nil
//        }
//        return UIImage(data: imageData)
//    }
    var imageFromBase64: UIImage? {
            guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
                return nil
            }
            return UIImage(data: imageData)
        }
}


extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self) {
            return UIImage(data: data)
        }
        return nil
    }
}
