//
//  DetailViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/04/12.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit
import CoreData
import CoreImage

class DetailViewController: UIViewController,MasterViewControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    private var referenceViewController:ReferenceViewController? = nil
    private var registrationViewController:RegistrationViewController? = nil
    
    @IBOutlet var detailView: UIView!
    var wine: Wine? = nil
    
    var pickerView: UIPickerView = UIPickerView()
    var vintageList:[String] = [""]
    let newImageName = "test_morning_sample"
    
    @IBOutlet weak var wineImageView: UIImageView!

    @IBOutlet weak var colorTextField: UITextField!
    //@IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var vintageTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!

    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "ワイン"
        
        //画像を設定する。
//        if(imageName != nil) {
//            wineImageView.image = UIImage(named: imageName)
//        }
        // カテゴリー
        self.initCategory()
        
        // ヴィンテージのpickerView
        self.initVintageList()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true

        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(DetailViewController.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(DetailViewController.cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        
        self.vintageTextField.inputView = pickerView
        self.vintageTextField.inputAccessoryView = toolbar
        
        //サブビュー
        self.referenceViewController = self.storyboard?.instantiateViewController(withIdentifier: "referenceViewController") as? ReferenceViewController
        self.view.addSubview((self.referenceViewController?.view)!)
        self.referenceViewController?.view.isHidden = true

        self.registrationViewController = self.storyboard?.instantiateViewController(withIdentifier: "registrationViewController") as? RegistrationViewController
        self.view.addSubview((self.registrationViewController?.view)!)
        self.registrationViewController?.view.isHidden = false
    }
    // カテゴリーの作成
    func initCategory(){
        self.categorySegmentedControl.removeAllSegments()
        var i = 0
        for elem in Category.enumerate() {
            let category = elem.element
            self.categorySegmentedControl.insertSegment(withTitle: category.description, at: i, animated: true)
            //self.categorySegmentedControl.setTitle(category.description, forSegmentAt: i)
            i += 1
            //print(category)  // White, Red, Rose, Sparkling
        }
        self.categorySegmentedControl.sizeToFit()
    }
    // ヴィンテージリストの作成
    func initVintageList(){
        let now = Date()
        // システムのカレンダーを取得
        let cal = Calendar.current
        
        // 現在時刻のDateComponentsを取り出す
        var dateComps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        let nowYear = dateComps.year!
        let startYear = nowYear - 50
        for year in startYear...nowYear {
            self.vintageList.append(String(year))
        }
    }
    //
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    // PickerViewの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // PickerViewの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return vintageList.count
    }
    // PickerViewの要素
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return vintageList[row]
    }
    // PickerView選択時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.vintageTextField.text = vintageList[row]
    }

    func cancel() {
        self.vintageTextField.text = ""
        self.vintageTextField.endEditing(true)
    }
    
    func done() {
        self.vintageTextField.endEditing(true)
    }

    //セル選択時の呼び出しメソッド
//    func selectedCell(image: UIImage) {
//        wineImageView.image = image
//    }
    func selectedCell(wine: Wine) {
        self.title = "ワインの更新"

        self.wine = wine
        self.nameTextField.text = wine.name
//        self.noteTextField.text = wine.note
        self.noteTextView.text = wine.note
        self.vintageTextField.text = String(wine.vintage)
        self.colorTextField.text = wine.color
        self.categorySegmentedControl.selectedSegmentIndex = Int(wine.category)
        if let image = wine.image {
            self.wineImageView.image = UIImage(data: image)
        }
        else{
            self.wineImageView.image = nil
        }
    }
    func addWine() {
        self.title = "ワインの追加"
        self.wine = nil
        self.nameTextField.text = nil
        //self.noteTextField.text = nil
        self.noteTextView.text = nil
        self.colorTextField.text = nil
        self.vintageTextField.text = nil
        self.categorySegmentedControl.selectedSegmentIndex = 0
        self.wineImageView.image = UIImage(named: self.newImageName)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func saveButtonTouchUpInside(_ sender: Any) {
        // ① UIAlertControllerクラスのインスタンスを生成
        // タイトル, メッセージ, Alertのスタイルを指定する
        // 第3引数のpreferredStyleでアラートの表示スタイルを指定する
        let alert: UIAlertController = UIAlertController(title: "保存", message: "保存してもいいですか？", preferredStyle:  UIAlertControllerStyle.alert)
        
        // ② Actionの設定
        // Action初期化時にタイトル, スタイル, 押された時に実行されるハンドラを指定する
        // 第3引数のUIAlertActionStyleでボタンのスタイルを指定する
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
            self.saveWine()
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
    // CoreData
    func saveWine(){

        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext

//        let entity = NSEntityDescription.entity(forEntityName: "Wine", in: viewContext)
//        let wine = NSManagedObject(entity:entity!,insertInto:viewContext) as! Wine
        var wine:Wine
        if self.wine != nil {
            // 更新
            wine = self.wine!
        }
        else {
            // 追加
            wine = Wine(context: viewContext)
        }
        wine.name = self.nameTextField.text
        //wine.note = self.noteTextField.text
        wine.note = self.noteTextView.text
        wine.color = self.colorTextField.text
        let vintageStr:String = self.vintageTextField.text!
        let vintage :Int16 = Int16(vintageStr)!
        wine.vintage = vintage
        wine.category = Int16(self.categorySegmentedControl.selectedSegmentIndex)

        //let imageNSData = NSData(data: (self.wineImageView.image?.jpegData)!)
        wine.image = self.wineImageView.image?.jpegData
        do{
            try viewContext.save()
            self.selectedCell(wine: wine)
        }catch{
            print(error)
        }
        self.reloadWineTableView()
    }
    func reloadWineTableView(){
        let masterNavController = self.splitViewController?.viewControllers.first as! UINavigationController
        let masterViewController = masterNavController.topViewController as! MasterViewController
        masterViewController.reloadWineTableView()
    }
    // ワイン画像の選択ボタン
    @IBAction func wineImageSelectTouchUpInside(_ sender: Any) {
        let alert = UIAlertController(title:"ワイン画像", message: "画像を選択してください。", preferredStyle: UIAlertControllerStyle.alert)
        
        let action1 = UIAlertAction(title: "ライブラリより選択", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) in
            print("アクション１をタップした時の処理")
            self.pickImageFromLibrary()
        })
        
        let action2 = UIAlertAction(title: "カメラを起動", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) in
            print("アクション２をタップした時の処理")
            self.pickImageFromCamera()
        })
        
        let cancel = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: {
            (action: UIAlertAction!) in
            print("キャンセルをタップした時の処理")
        })
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
        
        //        let actionSheet = UIAlertController(title:"Image", message: "Select the image", preferredStyle: UIAlertControllerStyle.actionSheet)
//        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {action in
//            // 何もしない
//        })
//        let actionNormal1 = UIAlertAction(title: "From Camera", style: UIAlertActionStyle.default, handler: {action in
//            self.pickImageFromCamera()
//        })
//        let actionNormal2 = UIAlertAction(title: "From Album", style: UIAlertActionStyle.default, handler: {action in
//            self.pickImageFromLibrary()
//        })
//        actionSheet.addAction(actionCancel)
//        actionSheet.addAction(actionNormal1)
//        actionSheet.addAction(actionNormal2)
//        
//        self.present(actionSheet, animated: true, completion: nil)
    }
    // Photo Libraryから選択
    func pickImageFromLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = false
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    // 写真を撮ってそれを選択
    func pickImageFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    //
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
            self.wineImageView.image = image
            //self.wineImageView.contentMode = UIViewContentMode.scaleAspectFill
        }
        // フォトライブラリの画像・写真選択画面を閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    func fit(image: UIImage,rect:CGRect) -> UIImage {
//https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CILanczosScaleTransform
        
        let inputImage = CIImage(image: image)
        let scaleFilter = CIFilter(name: "CILanczosScaleTransform")
        // フィルターに画像を設定
        scaleFilter?.setValue(inputImage, forKey: kCIInputImageKey)
        // スケールを変更
        scaleFilter?.setValue(NSNumber(value: 0.5), forKey: kCIInputScaleKey)
        // アスペクト比をキープ
        scaleFilter?.setValue(NSNumber(value: 1.0), forKey: kCIInputAspectRatioKey)
        let output = scaleFilter?.value(forKey: kCIOutputImageKey) as? CIImage
        let filteredImage = UIImage(ciImage: output!)
//        let outputImage:CIImage = (scaleFilter?.outputImage)!
//        let uiImage : UIImage = UIImage(ciImage: outputImage)
        return filteredImage
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
