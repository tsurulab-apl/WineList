//
//  MaterialRegistrationViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/07/23.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

class MaterialRegistrationViewController: AbstractRegistrationViewController,UIImagePickerControllerDelegate {

    // 資料
    private var material:Material?

    //
    let newImageName = "now_printing"

    // コントロール
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var formStackView: UIStackView!
    @IBOutlet weak var materialImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var materialTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var insertDateLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!
    ///
    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // 資料タイプの初期化
        self.initMaterialType()

        // noteの枠線
        self.noteTextView.layer.borderWidth = 0.5
        self.noteTextView.layer.borderColor = UIColor.lightGray.cgColor
    }

    ///
    /// didReceiveMemoryWarning
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return [self.nameTextField]
    }

    ///
    /// タイプの初期化
    ///
    func initMaterialType(){
        self.materialTypeSegmentedControl.removeAllSegments()
        var i = 0
        for elem in MaterialType.enumerate() {
            let materialType = elem.element
            self.materialTypeSegmentedControl.insertSegment(withTitle: materialType.description, at: i, animated: true)
            i += 1
        }
        self.materialTypeSegmentedControl.sizeToFit()
    }
    
    ///
    /// viewWillAppear
    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    ///
    /// CoreDataへの資料データ保存
    ///
    func save(){
        let materialList = self.getMaterialList()
        var material:Material
        if self.material != nil {
            // 更新
            material = self.material!
        }
        else {
            // 追加
            material = materialList.new()
        }
        material.name = self.nameTextField.text
        material.note = self.noteTextView.text
        let materialType = self.getMaterialTypeSegmentedControl()
        material.type = materialType.rawValue
        material.data = self.materialImageView.image?.jpegData

        let now = Date()
        if material.insertDate == nil {
            material.insertDate = now
        }
        material.updateDate = now
        materialList.save(data: material)
        
        let materialDetailViewController = self.parent as! MaterialDetailViewController
        materialDetailViewController.selectedCell(material: material)
        
        self.reloadMaterialTableView()
    }

    ///
    /// 選択されているタイプの取得
    ///
    func getMaterialTypeSegmentedControl() -> MaterialType {
        let index = self.materialTypeSegmentedControl.selectedSegmentIndex
        if let materialType = MaterialType.init(index: index) {
            return materialType
        }
        return MaterialType.other
    }
    
    ///
    /// テーブルビューのリロード
    ///
    func reloadMaterialTableView(){
        let materialDetailViewController = self.parent as! MaterialDetailViewController
        materialDetailViewController.reloadMaterialTableView()
    }
    
    ///
    /// 資料リストの取得
    ///
    func getMaterialList() -> DataList<Material> {
        let materialDetailViewController = self.parent as! MaterialDetailViewController
        let materialList = materialDetailViewController.getMaterialList()
        return materialList
    }
    
    ///
    /// セル選択時(delegate)
    ///
    func selectedCell(material: Material) {
        self.material = material
        self.nameTextField.text = material.name
        self.setMaterialTypeSegmentedControl(material: material)
        self.noteTextView.text = material.note
        if let image = material.data {
            self.materialImageView.image = UIImage(data: image)
        }
        else{
            self.materialImageView.image = nil
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd' 'HH:mm:ss"
        self.insertDateLabel.text = nil
        if let insertDate = material.insertDate {
            self.insertDateLabel.text = formatter.string(from: insertDate)
        }
        self.updateDateLabel.text = nil
        if let updateDate = material.updateDate {
            self.updateDateLabel.text = formatter.string(from: updateDate)
        }
    }

    ///
    /// 資料タイプのセグメントコントロールを選択
    ///
    func setMaterialTypeSegmentedControl(material: Material){
        var index = 0
        if let materialType = MaterialType.init(raw: material.type) {
            index = materialType.index
        }
        self.materialTypeSegmentedControl.selectedSegmentIndex = index
    }
    
    ///
    /// 資料の追加(delegate)
    ///
    func addMaterial() {
        self.material = nil
        self.materialImageView.image = UIImage(named: self.newImageName)
        self.nameTextField.text = nil
        self.materialTypeSegmentedControl.selectedSegmentIndex = 0
        self.noteTextView.text = nil
        self.insertDateLabel.text = nil
        self.updateDateLabel.text = nil
    }

    ///
    /// 画像ボタン
    ///
    @IBAction func imageSelectTouchUpInside(_ sender: Any) {
        let alert = UIAlertController(title:"資料画像", message: "画像を選択してください。", preferredStyle: UIAlertControllerStyle.alert)
        
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
    
    ///
    /// 写真選択時の処理
    ///
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        if info[UIImagePickerControllerOriginalImage] != nil {
            
            // アップ用画像の一時保存
            let originalImage: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            let editedImage: UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage
            //let wineImageSize: CGSize = CGSize(width: 256, height: 358)
            //let wineImageSize: CGSize = CGSize(width: 50, height: 50)
            var image: UIImage? = nil
            if editedImage != nil{
                //self.wineImageView.image = editedImage?.resize(size: wineImageSize)
                //self.wineImageView.image = editedImage?.fit(rect: self.wineImageView.frame)
                //self.wineImageView.image = self.fit(image: editedImage!,rect: self.wineImageView.frame)
                image = editedImage
            }
            else {
                //self.wineImageView.image = originalImage.resize(size: wineImageSize)
                //self.wineImageView.image = originalImage.fit(rect: self.wineImageView.frame)
                //self.wineImageView.image = self.fit(image: originalImage,rect: self.wineImageView.frame)
                image = originalImage
            }
            self.materialImageView.image = image
        }
        // フォトライブラリの画像・写真選択画面を閉じる
        picker.dismiss(animated: true, completion: nil)
    }

    ///
    /// 保存ボタン
    ///
    @IBAction func saveButtonTouchUpInside(_ sender: Any) {
        // ① UIAlertControllerクラスのインスタンスを生成
        // タイトル, メッセージ, Alertのスタイルを指定する
        // 第3引数のpreferredStyleでアラートの表示スタイルを指定する
        let alert: UIAlertController = UIAlertController(title: "保存", message: "保存します。よろしいですか？", preferredStyle:  UIAlertControllerStyle.alert)
        
        // ② Actionの設定
        // Action初期化時にタイトル, スタイル, 押された時に実行されるハンドラを指定する
        // 第3引数のUIAlertActionStyleでボタンのスタイルを指定する
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
            self.save()
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        // ③ UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        // ④ Alertを表示
        present(alert, animated: true, completion: nil)
    }

    ///
    /// リセットボタン
    ///
    @IBAction func resetButtonTouchUpInside(_ sender: Any) {
        if self.material != nil {
            self.selectedCell(material: self.material!)
        }
        else{
            self.addMaterial()
        }
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
