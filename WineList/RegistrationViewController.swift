//
//  RegistrationViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/05/06.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var vintageTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var wineImageView: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var displaySwitch: UISwitch!

    @IBOutlet weak var insertDateLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!

    var pickerView: UIPickerView = UIPickerView()
    var vintageList:[String] = [""]
    let newPrice = 5000
    let newImageName = "test_morning_sample"

    var wine: Wine? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        print("RegistrationViewController.viewDidLoad")

        self.title = "ワイン"
        
        // カテゴリー
        self.initCategory()
        
        // ヴィンテージのpickerView
        self.initVintagePickerView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    // ヴィンテージピッカービューの作成
    func initVintagePickerView(){
        self.initVintageList()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        let toolbar = UIToolbar(frame: CGRect(x:0.0, y:0.0, width:0.0, height:35.0))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        
        self.vintageTextField.inputView = pickerView
        self.vintageTextField.inputAccessoryView = toolbar
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
    // PickerViewのdoneボタン
    func done() {
        self.vintageTextField.endEditing(true)
    }
    // PickerViewのcancelボタン
    func cancel() {
        self.vintageTextField.text = ""
        self.vintageTextField.endEditing(true)
    }
    // 写真ボタン
    @IBAction func imageSelectTouchUpInside(_ sender: Any) {
        print("imageSelectTouchUpInside")
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
    // 写真選択時の処理
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
    
    // 保存ボタン
    @IBAction func saveTouchUpInside(_ sender: Any) {
        print("saveTouchUpInside")
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
    // リセットボタン
    @IBAction func resetTouchUpInside(_ sender: Any) {
        print("resetTouchUpInside")
        if self.wine != nil {
            self.selectedCell(wine: self.wine!)
        }
        else{
            self.addWine()
        }
    }
    // マスターテーブルで選択されたワインの更新
    func selectedCell(wine: Wine) {
        self.title = "ワインの更新"
        
        self.wine = wine
        self.nameTextField.text = wine.name
        self.noteTextView.text = wine.note
        self.vintageTextField.text = String(wine.vintage)
        self.categorySegmentedControl.selectedSegmentIndex = Int(wine.category)
        self.priceTextField.text = String(wine.price)
        self.displaySwitch.isOn = wine.display
        if let image = wine.image {
            self.wineImageView.image = UIImage(data: image)
        }
        else{
            self.wineImageView.image = nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd' 'HH:mm:ss"
        self.insertDateLabel.text = nil
        if let insertDate = wine.insertDate {
            self.insertDateLabel.text = formatter.string(from: insertDate)
        }
        self.updateDateLabel.text = nil
        if let updateDate = wine.updateDate {
            self.updateDateLabel.text = formatter.string(from: updateDate)
        }
    }
    // ワインの追加
    func addWine() {
        self.title = "ワインの追加"
        self.wine = nil
        self.nameTextField.text = nil
        self.noteTextView.text = nil
        self.vintageTextField.text = nil
        self.categorySegmentedControl.selectedSegmentIndex = 0
        self.priceTextField.text = String(newPrice)
        self.displaySwitch.isOn = true
        self.wineImageView.image = UIImage(named: self.newImageName)
        self.insertDateLabel.text = nil
        self.updateDateLabel.text = nil
    }
    // CoreDataへのワインデータ保存
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
        wine.note = self.noteTextView.text

        let vintage = self.textFieldToInt16(textField: self.vintageTextField)
        wine.vintage = vintage

        wine.category = Int16(self.categorySegmentedControl.selectedSegmentIndex)

        let price = self.textFieldToInt16(textField: self.priceTextField)
        wine.price = price

        wine.display = self.displaySwitch.isOn
        
        wine.image = self.wineImageView.image?.jpegData

        let now = Date()
        if wine.insertDate == nil {
            wine.insertDate = now
        }
        wine.updateDate = now

        do{
            try viewContext.save()
            self.selectedCell(wine: wine)
        }catch{
            print(error)
        }

        self.reloadWineTableView()
    }
    // テキストフィールドの値をInt16で取得
    func textFieldToInt16(textField: UITextField) -> Int16 {
        let str:String = textField.text!
        let num :Int16 = Int16(str)!
        return num
    }
    // マスターテーブルのリロード
    func reloadWineTableView(){
        let detailViewController = self.parent as! DetailViewController
        detailViewController.reloadWineTableView()
        /****
        //let detailViewController = self.parent
        //let masterNavController = detailViewController?.splitViewController?.viewControllers.first as! UINavigationController
        let masterNavController = self.splitViewController?.viewControllers.first as! UINavigationController
        let masterViewController = masterNavController.topViewController as! MasterViewController
        masterViewController.reloadWineTableView()
        ****/
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
