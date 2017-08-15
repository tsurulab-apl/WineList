//
//  SelectableImage.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/08/10.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
import UIKit

///
/// 画像の選択状態
///
public enum SelectableImageStatus {
    case nothing    // 何もしていない状態
    case selected   // 画像を選択した状態
    case cleared    // 画像をクリアした状態
}

///
/// 画像選択機能のプロトコル
/// 利用する際に画像の選択状態を管理するプロパティーと画像を表示するイメージビューを実装すること。
///
protocol SelectableImage:UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    ///
    /// 画像の選択状態管理用プロパティーの取得
    ///
    func get() -> SelectableImageStatus

    ///
    /// 画像の選択状態管理用プロパティーの設定
    ///
    func set(selectableImageStatus:SelectableImageStatus)

    ///
    /// イメージビューの取得
    ///
    func get() -> UIImageView
}

///
/// 画像選択機能のプロトコル拡張
///
extension SelectableImage where Self: AbstractRegistrationViewController {

    ///
    /// 写真選択アクション
    ///
    func selectImageAction() {
        let alert = UIAlertController(title:"ワイン画像", message: "画像を選択してください。", preferredStyle: UIAlertControllerStyle.alert)
        
        let action1 = UIAlertAction(title: "ライブラリより選択", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) in
            self.pickImageFromLibrary()
        })
        
        let action2 = UIAlertAction(title: "カメラを起動", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) in
            self.pickImageFromCamera()
        })
        
        let cancel = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: {
            (action: UIAlertAction!) in
        })
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(cancel)
  
        self.present(alert, animated: true, completion: nil)
    }
    
    ///
    /// クリアアクション
    ///
    func clearImageAction() {
        let imageView:UIImageView = self.get()
        imageView.image = Settings.instance.defaultDefaultImage
        self.set(selectableImageStatus: SelectableImageStatus.cleared)
    }
    
    ///
    /// Photo Libraryから選択
    ///
    func pickImageFromLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = false
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    ///
    /// 写真を撮ってそれを選択
    ///
    func pickImageFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    ///
    /// 写真選択時の処理
    /// 利用側でimagePickerControllerメソッドを実装し、このメソッドを呼び出す。
    ///
    func imagePickerControllerAction(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if info[UIImagePickerControllerOriginalImage] != nil {
            
            // 画像の保存
            let originalImage: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            let editedImage: UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage
            var image: UIImage? = nil
            if editedImage != nil{
                image = editedImage
            }
            else {
                image = originalImage
            }
            let imageView:UIImageView = self.get()
            imageView.image = image
            // 画像を変更対象としてマーク
            self.set(selectableImageStatus: SelectableImageStatus.selected)
        }
        // フォトライブラリの画像・写真選択画面を閉じる
        picker.dismiss(animated: true, completion: nil)
    }
}
