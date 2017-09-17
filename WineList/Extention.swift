//
//  extention.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/04/22.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

/// UIImage Extension リサイズメソッド
///
extension UIImage {

    /// リサイズ
    ///
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
    
    /// フィット
    ///
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
    
    /// JPEG
    ///
    var jpegData: Data {
        return UIImageJPEGRepresentation(self, 1.0)!
    }
    
    /// PNG
    ///
    var pngData: Data {
        return UIImagePNGRepresentation(self)!
    }
}

/// UIColor
///
extension UIColor {
    class func rgb(r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    static var blue2: UIColor {
        return UIColor.rgb(r: 66,g: 134,b: 244,alpha: 1.0)
    }
}

/// UIScrollView
/// 画面をタッチした際にキーボードやPickerViewを閉じる対応をUIScrollViewでも実現
/// 可能なようにtouchesBeganを作成する。
/// http://qiita.com/nao-otsu/items/a2b60098a702ab1852c6
extension UIScrollView {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
    }
}

/// UITextField
///
extension UITextField {
    
    /// 必須チェック
    ///
    /// - Returns: true:成功 false:失敗
    func requiredCheck() -> Bool {
        var valid = true
        if let text = self.text {
            let value = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if value == "" {
                valid = false
            }
        } else {
            valid = false
        }
        return valid
    }
}

/// UIImagePickerController
///
extension UIImagePickerController {
    
    /// 回転の許可
    /// UIImagePickerControllerはデフォルトでは縦(portrait)でしか利用できない。
    /// これを縦横すべて利用可能なように設定する。
    /// ライブラリ選択もカメラ起動も両方とも縦横回転を可能とする。
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            if self.sourceType == .camera {
                //return .portrait
                return .all
            } else { //.photoLibrary
                //return .portrait
                //return .landscape
                return .all
            }
        }
    }
}
