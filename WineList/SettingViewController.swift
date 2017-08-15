//
//  SettingViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/06/13.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

///
/// SettingViewController
///
//class SettingViewController: AbstractRegistrationViewController,UIImagePickerControllerDelegate {
class SettingViewController: AbstractRegistrationViewController,SelectableImage {

    // 設定クラス
    private let settings = Settings.instance
    
    // ナビゲーションバーボタン
    private var saveButton:UIBarButtonItem

    // コントロール
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var formStackView: UIStackView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var longPressDurationLabel: UILabel!
    @IBOutlet weak var longPressDurationSlider: UISlider!
    @IBOutlet weak var defaultImageView: UIImageView!

    // 画面呼出時のデータ表示フラグ
    // DetailViewControllerから呼び出す際にfalseに設定し、
    // showDataメソッド完了時にtrueに更新する。
    // viewWillAppear内で判定し、写真選択画面から戻った際には、
    // 再度データ表示を実施しないように制御する。
    var dataShowed: Bool = false

    // デフォルト画像の状態
    var defaultImageStatus = SelectableImageStatus.nothing
    
    // デフォルト画像の状態 true:選択済 false:選択なし
//    var selectImage: Bool = false

    // デフォルト画像のクリア状態 true:クリア false:クリア以外
//    var clearImage: Bool = false

    ///
    /// イニシャライザ
    ///
    required init?(coder aDecoder: NSCoder) {
        // BarButton
        self.saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
        
        super.init(coder: aDecoder)
        // super.initの後にselfを設定可能
        self.saveButton.target = self
        self.saveButton.action = #selector(saveButtonAction(_:))
    }

    ///
    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "設定"

        // ナビゲーションバーボタンの作成
        self.navigationItem.setRightBarButtonItems([self.saveButton], animated: true)

        // Do any additional setup after loading the view.
    }

    ///
    /// スクロールビューを戻す。
    ///
    override func getScrollView() -> UIScrollView {
        return self.mainScrollView
    }

    ///
    /// スクロールビューでズームするビューを戻す。
    ///
    override func getZoomView() -> UIView? {
        return self.formStackView
    }

    ///
    /// delegate設定するUITextFiledの配列を戻す。
    ///
    override func getUITextFields() -> [UITextField] {
        return [self.passwordTextField]
    }

    ///
    /// 画像選択プロトコル拡張に対してイメージビューを戻す。
    ///
    func get() -> UIImageView {
        return self.defaultImageView
    }
    
    ///
    /// 画像選択プロトコル拡張に対して画像選択状態を戻す。
    ///
    func get() -> SelectableImageStatus {
        return self.defaultImageStatus
    }

    ///
    /// 画像選択プロトコル拡張の画像の選択状態管理用プロパティーの設定
    ///
    func set(selectableImageStatus:SelectableImageStatus) {
        self.defaultImageStatus = selectableImageStatus
    }
    
    ///
    /// viewWillAppear
    ///
    override func viewWillAppear(_ animated: Bool) {
        //print("SettingViewController#viewWillAppear")
        super.viewWillAppear(animated)

        // DetailViewControllerから遷移した場合のみデータ表示を行う。
        // 写真選択から戻った際には何もしない。
        if !self.dataShowed {
            self.showData()
            self.dataShowed = true
        }
    }

    ///
    /// didReceiveMemoryWarning
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    ///
    /// ナビゲーションバーの保存ボタン
    ///
    func saveButtonAction(_ sender: Any){
        self.savePassword()
        self.saveLongPressDuration()
        self.saveDefaultImage()
        // 変更を反映
        self.settings.notice()
        // 画面を閉じる
        self.navigationController?.popViewController(animated: true)
    }
    
    ///
    /// データの表示
    ///
    func showData(){
        self.passwordTextField.text = settings.password
        let longPressDuration = self.settings.longPressDuration
        self.longPressDurationSlider.value = Float(longPressDuration)
        self.longPressDurationSliderValueChanged(self.longPressDurationSlider)
        self.defaultImageView.image = self.settings.defaultImage
        self.defaultImageStatus = SelectableImageStatus.nothing
//        self.selectImage = false
//        self.clearImage = false
    }
    
    ///
    /// パスワードの保存
    ///
    func savePassword(){
        // nilは保存しないが、空文字はそのまま保存する。
        if let password = self.passwordTextField.text {
            self.settings.password = password
            //self.settings.set(password:password)
        }
    }

    ///
    /// 長押し設定の保存
    ///
    func saveLongPressDuration(){
        var longPressDuration = self.longPressDurationSlider.value
        longPressDuration = roundf(longPressDuration * 10) /  10
        self.settings.longPressDuration = Double(longPressDuration)
    }

    ///
    /// デフォルト画像の保存
    ///
    func saveDefaultImage(){
/**********
        if self.selectImage {
            let image = self.defaultImageView.image
            self.settings.defaultImage = image!
        }
        else if self.clearImage {
            self.settings.clearDefaultImage()
        }
**************/
        switch self.defaultImageStatus {
        case SelectableImageStatus.selected:
            let image = self.defaultImageView.image
            self.settings.defaultImage = image!
            break
        case SelectableImageStatus.cleared:
            self.settings.clearDefaultImage()
            break
        default:
            // 保存しない。
            break
        }
    }
    
    ///
    /// 長押し設定の値変更時
    ///
    @IBAction func longPressDurationSliderValueChanged(_ sender: UISlider) {
        var second = sender.value
        second = roundf(second * 10) /  10
        self.longPressDurationLabel.text = "\(second)s"
    }
    
    ///
    /// 写真ボタン
    ///
    @IBAction func imageSelectTouchUpInside(_ sender: Any) {
        self.selectImageAction()
/********
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
**********/
    }
    
    ///
    /// クリアボタン
    ///
    @IBAction func imageClearTouchUpInside(_ sender: Any) {
        self.clearImageAction()
/**********
        self.defaultImageView.image = self.settings.defaultDefaultImage
        self.clearImage = true
        self.selectImage = false
***********/
    }
    
/*********
    ///
    /// Photo Libraryから選択
    ///
    func pickImageFromLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = false
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
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
            present(imagePickerController, animated: true, completion: nil)
        }
    }
************/
    
    ///
    /// 写真選択時の処理
    ///
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        // プロトコル拡張のメソッドに処理を委譲する。
        self.imagePickerControllerAction(picker, didFinishPickingMediaWithInfo: info)
/*********
        if info[UIImagePickerControllerOriginalImage] != nil {
            
            let originalImage: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            let editedImage: UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage
            var image: UIImage? = nil
            if editedImage != nil{
                image = editedImage
            }
            else {
                image = originalImage
            }
            self.defaultImageView.image = image
            // 画像を変更対象としてマーク
            self.defaultImageStatus = SelectableImageStatus.selected
//            self.selectImage = true
//            self.clearImage = false
        }
        // フォトライブラリの画像・写真選択画面を閉じる
        picker.dismiss(animated: true, completion: nil)
*************/
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
