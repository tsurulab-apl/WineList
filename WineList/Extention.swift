//
//  extention.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/04/22.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

// UIImage Extension リサイズメソッド
extension UIImage {
    
    func resize(size: CGSize) -> UIImage {
        let widthRatio = size.width / self.size.width
        let heightRatio = size.height / self.size.height
        let ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio
        let resizedSize = CGSize(width: (self.size.width * ratio), height: (self.size.height * ratio))
        // 画質を落とさないように以下を修正
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    func fit(rect:CGRect) -> UIImage {
        let inputImage = CIImage(image: self)
        let scaleFilter = CIFilter(name: "CILanczosScaleTransform")
        // フィルターに画像を設定
        scaleFilter?.setValue(inputImage, forKey: kCIInputImageKey)
        // スケールを変更
        scaleFilter?.setValue(NSNumber(value: 0.5), forKey: kCIInputScaleKey)
        // アスペクト比をキープ
        scaleFilter?.setValue(NSNumber(value: 1.0), forKey: kCIInputAspectRatioKey)
        let outputImage:CIImage = (scaleFilter?.outputImage)!
        let uiImage : UIImage = UIImage(ciImage: outputImage)
        return uiImage
    }
    var jpegData: Data {
        return UIImageJPEGRepresentation(self, 1.0)!
    }
    var pngData: Data {
        return UIImagePNGRepresentation(self)!
    }
}
// UIColor
extension UIColor {
    class func rgb(r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    static var blue2: UIColor {
        return UIColor.rgb(r: 66,g: 134,b: 244,alpha: 1.0)
    }
}
