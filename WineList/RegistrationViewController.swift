//
//  RegistrationViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/05/06.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

//class RegistrationViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate,UIScrollViewDelegate {
//class RegistrationViewController: AbstractRegistrationViewController,UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate, DataListDelegate {

/// ワイン登録画面
class RegistrationViewController: AbstractRegistrationViewController,UIPickerViewDataSource,UIPickerViewDelegate, DataListDelegate, SelectableImage {

    // コントロール
    @IBOutlet weak var formStackView: UIStackView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var vintageTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var aliasTextField: UITextField!
    @IBOutlet weak var wineryTextField: UITextField!
    @IBOutlet weak var wineImageView: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var displaySwitch: UISwitch!

    @IBOutlet weak var insertDateLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!

    var pickerView: UIPickerView = UIPickerView()
    var vintageList:[String] = [""]
    let newPrice = 5000
    //let newImageName = "two-types-of-wine-1761613_640.jpg"

    // 処理中のワイン
    var wine: Wine? = nil

    // ワイン画像の状態 true:選択済 false:選択なし
    //var selectImage: Bool = false

    // ワイン画像の状態
    var imageStatus = SelectableImageStatus.nothing

    // 資料選択のワーク
    var materials: [Material] = []
    
/**********:
    // キーボード表示時にテキストフィールドやテキストビューが隠れないようにスクロールする対応用
    var activeText:UIView?
    let scrollMargin:Float = 8.0
*************/
    
    ///
    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ワイン登録"
        
        // カテゴリー
        self.initCategory()
        
        // ヴィンテージのpickerView
        self.initVintagePickerView()

        // noteの枠線
        self.noteTextView.layer.borderWidth = 0.5
        self.noteTextView.layer.borderColor = UIColor.lightGray.cgColor

        // カテゴリー変更時のdelegate設定
        let categoryList = self.getCategoryList()
        categoryList.set(delegate: self)
        
/********
        // スクロールビューのdelegate設定
        self.mainScrollView.delegate = self

        // テキストフィールド、テキストビューのdelegate設定 改行(Enter)時のキーボード閉じる対応用
        self.nameTextField.delegate = self
        self.aliasTextField.delegate = self
        self.priceTextField.delegate = self
        self.noteTextView.delegate = self
***********/
    }

    ///
    /// カテゴリーの変更時処理
    ///
    func changeDataList(type: LinkedData.Type) {
        if type is Category.Type {
            // セグメントコントロールを作成し直す。
            self.initCategory()
        }
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
        return [self.nameTextField, self.aliasTextField, self.wineryTextField, self.vintageTextField, self.priceTextField]
    }

    ///
    /// delegate設定するUITextViewの配列を戻す。
    ///
    override func getUITextViews() -> [UITextView] {
        return [self.noteTextView]
    }

    ///
    /// 画像選択プロトコル拡張に対してイメージビューを戻す。
    ///
    func get() -> UIImageView {
        return self.wineImageView
    }
    
    ///
    /// 画像選択プロトコル拡張に対して画像選択状態を戻す。
    ///
    func get() -> SelectableImageStatus {
        return self.imageStatus
    }
    
    ///
    /// 画像選択プロトコル拡張の画像の選択状態管理用プロパティーの設定
    ///
    func set(selectableImageStatus:SelectableImageStatus) {
        self.imageStatus = selectableImageStatus
    }
    
    ///
    /// didReceiveMemoryWarning
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    ///
    /// viewWillAppear
    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
/******
        // キーボード表示時のスクロール対応
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(RegistrationViewController.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(RegistrationViewController.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
*********/
    }
    ///
    /// キーボードを表示する際にテキストフィールドやテキストビューと重複しないようスクロールを調整する。
    ///
/***************
    func keyboardWillShowNotification(_ notification: Notification) {
        if let activeText = self.activeText {
            if let userInfo = notification.userInfo {
                // キーボードの上端を取得
                let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let boundSize = UIScreen.main.bounds.size
                let keyboardTop = boundSize.height - keyboardEndFrame.size.height
                print("キーボードの上端：(\(keyboardTop))")

                // テキストフィールド、テキストビューの下端を取得
                let textRect = activeText.superview?.convert(activeText.frame, to: nil)
                let textBottom = (textRect?.origin.y)! + (textRect?.height)! + CGFloat(self.scrollMargin)
                print("テキストフィールドの下端：(\(textBottom))")

                // テキストフィールド、テキストビューがキーボードに隠れている場合は、スクロールを調整。
                if textBottom >= keyboardTop {
                    let scroll = textBottom - keyboardTop
                    self.mainScrollView.contentOffset.y = scroll
                }
            }
            // activeTextを初期化
            self.activeText = nil
        }
    }
*************/
    ///
    /// キーボードの表示を終了する際にスクロールを元に戻す。
    ///
/*************
    func keyboardWillHideNotification(_ notification: Notification) {
        self.mainScrollView.contentOffset.y = 0
    }
***************/
    ///
    /// 改行(Enter)時にキーボードを閉じる
    /// 名前、価格
    ///
/*****************
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
*******************/
    ///
    /// UITextFieldの編集を開始した際
    /// activeTextに自身を保存し、キーボードのスクロールを制御する。
    ///
/***************
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.activeText = textField
        return true
    }
*******************/
    ///
    /// UITextViewの編集を開始した際
    /// activeTextに自身を保存し、キーボードのスクロールを制御する。
    ///
/**********************
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.activeText = textView
        return true
    }
******************/
    ///
    /// スクロールビューのZoom対象を戻す。
    ///
/**********
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        // return a view that will be scaled. if delegate returns nil, nothing happens
        return self.formStackView
    }
************/
    ///
    /// カテゴリーの作成
    ///
    func initCategory(){
        self.categorySegmentedControl.removeAllSegments()
        var i = 0
        let categoryList = self.getCategoryList()
        for category in categoryList {
            self.categorySegmentedControl.insertSegment(withTitle: category.name, at: i, animated: true)
            i += 1
        }
        self.categorySegmentedControl.sizeToFit()

        // ワインを表示中の場合は、セグメントコントロールを選択し直す。
        if let wine = self.wine {
            self.setCategorySegmentedControl(wine: wine)
        }
    }
//    func initCategory(){
//        self.categorySegmentedControl.removeAllSegments()
//        var i = 0
//        for elem in CategoryEnum.enumerate() {
//            let category = elem.element
//            self.categorySegmentedControl.insertSegment(withTitle: category.description, at: i, animated: true)
//            //self.categorySegmentedControl.setTitle(category.description, forSegmentAt: i)
//            i += 1
//            //print(category)  // White, Red, Rose, Sparkling
//        }
//        self.categorySegmentedControl.sizeToFit()
//    }
    ///
    /// ヴィンテージピッカービューの作成
    ///
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
    
    ///
    /// ヴィンテージリストの作成
    ///
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
    
    ///
    /// PickerViewの列数
    ///
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    ///
    /// PickerViewの行数
    ///
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return vintageList.count
    }
    
    ///
    /// PickerViewの要素
    ///
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return vintageList[row]
    }
    
    ///
    /// PickerView選択時
    ///
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.vintageTextField.text = vintageList[row]
    }
    
    ///
    /// PickerViewのdoneボタン
    ///
    func done() {
        self.vintageTextField.endEditing(true)
    }
    
    ///
    /// PickerViewのcancelボタン
    ///
    func cancel() {
        self.vintageTextField.text = ""
        self.vintageTextField.endEditing(true)
    }
    
    ///
    /// PickerViewやキーボードを閉じる
    ///
/******
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("touchesBegan vintageTextField.isEditing=" + String(self.vintageTextField.isEditing))
        if (self.nameTextField.isEditing){
            self.nameTextField.endEditing(true)
        }
        if (self.aliasTextField.isEditing){
            self.aliasTextField.endEditing(true)
        }
        if (self.vintageTextField.isEditing){
            self.vintageTextField.endEditing(true)
        }
        //if (self.noteTextView){
        self.noteTextView.endEditing(true)
        //}
        if (self.priceTextField.isEditing){
            self.priceTextField.endEditing(true)
        }
    }
**********/
    
    ///
    /// 写真ボタン
    ///
    @IBAction func imageSelectTouchUpInside(_ sender: Any) {
        self.selectImageAction()
/***********
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
*************/
    }
    
    /// クリアボタン
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func imageClearTouchUpInside(_ sender: Any) {
        self.clearImageAction()
    }

/**************
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
 
    /// 写真選択時の処理
    ///
    /// - Parameters:
    ///   - picker: <#picker description#>
    ///   - info: <#info description#>
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // プロトコル拡張のメソッドに処理を委譲する。
        self.imagePickerControllerAction(picker, didFinishPickingMediaWithInfo: info)
/*************
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
            // 画像を変更対象としてマーク
            self.selectImage = true
            //self.wineImageView.contentMode = UIViewContentMode.scaleAspectFill
        }
        // フォトライブラリの画像・写真選択画面を閉じる
        picker.dismiss(animated: true, completion: nil)
************/
    }
    
    ///
    /// 保存ボタン
    ///
    @IBAction func saveTouchUpInside(_ sender: Any) {
        print("saveTouchUpInside")
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

    ///
    /// リセットボタン
    ///
    @IBAction func resetTouchUpInside(_ sender: Any) {
        print("resetTouchUpInside")
        if self.wine != nil {
            self.selectedCell(wine: self.wine!)
        }
        else{
            self.addWine()
        }
    }

    ///
    /// マスターテーブルで選択されたワインの更新
    ///
    func selectedCell(wine: Wine) {
        self.title = "ワインの更新"
        
        self.wine = wine
        self.nameTextField.text = wine.name
        self.aliasTextField.text = wine.alias
        self.wineryTextField.text = wine.winery
        self.noteTextView.text = wine.note
        self.vintageTextField.text = String(wine.vintage)
        //self.categorySegmentedControl.selectedSegmentIndex = Int(wine.category)
        self.setCategorySegmentedControl(wine: wine)
        self.priceTextField.text = String(wine.price)
        self.displaySwitch.isOn = wine.display
        if let image = wine.image {
            self.wineImageView.image = UIImage(data: image)
        }
        else{
            //self.wineImageView.image = nil
            //self.wineImageView.image = UIImage(named: self.newImageName)
            self.wineImageView.image = Settings.instance.defaultImage
        }
        //self.selectImage = false
        self.imageStatus = SelectableImageStatus.nothing
        self.materials.removeAll()
        if let materials = wine.materials {
            for material in materials {
                self.materials.append(material as! Material)
            }
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

    ///
    /// カテゴリーを選択
    ///
    func setCategorySegmentedControl(wine: Wine){
        let wineList = self.getWineList()
        let categoryList = wineList.categoryList
        let index = categoryList.index(data: wine.category!)
        self.categorySegmentedControl.selectedSegmentIndex = index
    }

    ///
    /// ワインの追加(空画面の生成)
    ///
    func addWine() {
        self.title = "ワインの追加"
        self.wine = nil
        self.materials.removeAll()
        self.nameTextField.text = nil
        self.aliasTextField.text = nil
        self.wineryTextField.text = nil
        self.noteTextView.text = nil
        self.vintageTextField.text = nil
        self.categorySegmentedControl.selectedSegmentIndex = 0
        self.priceTextField.text = String(newPrice)
        self.displaySwitch.isOn = true
        //self.wineImageView.image = UIImage(named: self.newImageName)
        self.wineImageView.image = Settings.instance.defaultImage
        //self.selectImage = false
        self.imageStatus = SelectableImageStatus.nothing
        self.insertDateLabel.text = nil
        self.updateDateLabel.text = nil
    }

    ///
    /// ワインリストの取得
    ///
    func getWineList() -> WineList {
        let detailViewController = self.parent as! DetailViewController
        let wineList = detailViewController.getWineList()
        return wineList
    }

    ///
    /// カテゴリーリストの取得
    ///
    func getCategoryList() -> DataList<Category> {
        let wineList = self.getWineList()
        let categoryList = wineList.categoryList
        return categoryList
    }
    
    ///
    /// CoreDataへのワインデータ保存
    ///
    func saveWine(){
        let wineList = self.getWineList()
        //let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        //let viewContext = appDelegate.persistentContainer.viewContext
        
        //        let entity = NSEntityDescription.entity(forEntityName: "Wine", in: viewContext)
        //        let wine = NSManagedObject(entity:entity!,insertInto:viewContext) as! Wine
        var wine:Wine
        if self.wine != nil {
            // 更新
            wine = self.wine!
        }
        else {
            // 追加
            //wine = Wine(context: viewContext)
            wine = wineList.newWine()
        }
        wine.name = self.nameTextField.text
        wine.alias = self.aliasTextField.text
        wine.winery = self.wineryTextField.text
        wine.note = self.noteTextView.text

        // ヴィンテージ
        let vintage = self.textFieldToInt16(textField: self.vintageTextField)
        wine.vintage = vintage

        // カテゴリー
        //wine.category = Int16(self.categorySegmentedControl.selectedSegmentIndex)
        let categoryList = wineList.categoryList
        let category = categoryList.get(self.categorySegmentedControl.selectedSegmentIndex)
        //wine.category = category
        wine.changeCategory(category)

        // 価格
        let price = self.textFieldToInt32(textField: self.priceTextField)
        wine.price = price

        // 表示
        wine.display = self.displaySwitch.isOn

        // 画像
        switch self.imageStatus {
        case SelectableImageStatus.selected:
            let image = self.wineImageView.image
            wine.image = image?.jpegData
            break
        case SelectableImageStatus.cleared:
            wine.image = nil
            break
        default:
            // 保存しない。
            break
        }
//        if self.selectImage {
//            wine.image = self.wineImageView.image?.jpegData
//        }
        // 資料
        wine.materials = nil
        for material in self.materials {
            wine.addToMaterials(material)
        }

        // 登録日時、更新日時
        let now = Date()
        if wine.insertDate == nil {
            wine.insertDate = now
        }
        wine.updateDate = now
/***
        do{
            try viewContext.save()
            let detailViewController = self.parent as! DetailViewController
            detailViewController.selectedCell(wine: wine)
            //self.selectedCell(wine: wine)
        }catch{
            print(error)
        }
***/
        wineList.save(wine: wine)
        let detailViewController = self.parent as! DetailViewController
        detailViewController.selectedCell(wine: wine)

        self.reloadWineTableView()
    }
    
    ///
    /// テキストフィールドの値をInt16で取得
    ///
    func textFieldToInt16(textField: UITextField) -> Int16 {
        let str:String = textField.text!
        let num :Int16 = Int16(str)!
        return num
    }
    
    ///
    /// テキストフィールドの値をInt32で取得
    ///
    func textFieldToInt32(textField: UITextField) -> Int32 {
        let str:String = textField.text!
        let num :Int32 = Int32(str)!
        return num
    }
    
    ///
    /// マスターテーブルのリロード
    ///
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
     */
    ///
    /// セグエによる遷移時
    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        // 資料選択ポップアップ
        if segue.identifier == "PopupMaterialSelect" {
            let popupMaterialSelectViewController = segue.destination as! PopupMaterialSelectViewController
            popupMaterialSelectViewController.registrationViewController = self
            //popupMaterialSelectViewController.materials = self.materials
        }
    }
}
