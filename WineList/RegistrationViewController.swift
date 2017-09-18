//
//  RegistrationViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/05/06.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

/// ワイン登録画面
///
class RegistrationViewController: AbstractRegistrationViewController,UIPickerViewDataSource,UIPickerViewDelegate, DataListDelegate, SettingsDelegate, SelectableImage {

    /// 設定クラス
    private let settings = Settings.instance

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
    @IBOutlet weak var priceAskSwitch: UISwitch!
    @IBOutlet weak var displaySwitch: UISwitch!

    @IBOutlet weak var insertDateLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!

    /// ヴィンテージピッカービュー
    var pickerView: UIPickerView = UIPickerView()
    
    /// ヴィンテージの選択肢
    var vintageList:[String] = [""]

    /// 処理中のワイン
    var wine: Wine? = nil

    /// ワイン画像の状態
    var imageStatus = SelectableImageStatus.nothing

    /// 資料選択のワーク
    var materialsWork: Set<Material> = []
    
    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = "ワイン登録"
        
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

        // 設定変更時のdelegate設定
        self.settings.set(delegate: self)
    }

    /// カテゴリーの変更時処理
    ///
    /// - Parameter type: リンクデータの型(カテゴリー)
    func changeDataList(type: LinkedData.Type) {
        if type is Category.Type {
            // セグメントコントロールを作成し直す。
            self.initCategory()
        }
    }

    /// 設定変更の反映
    ///
    func changeSettings() {
        // ヴィンテージリストを更新
        self.initVintageList()
    }
    
    /// スクロールビューを戻す。
    ///
    /// - Returns: スクロールビュー
    override func getScrollView() -> UIScrollView {
        return self.mainScrollView
    }
    
    /// スクロールビューでズームするビューを戻す。
    ///
    /// - Returns: スクロールビューでズームするビュー
    override func getZoomView() -> UIView? {
        return self.formStackView
    }

    /// delegate設定するUITextFiledの配列を戻す。
    ///
    /// - Returns: UITextFieldの配列
    override func getUITextFields() -> [UITextField] {
        return [self.nameTextField, self.aliasTextField, self.wineryTextField, self.vintageTextField, self.priceTextField]
    }

    /// delegate設定するUITextViewの配列を戻す。
    ///
    /// - Returns: UITextViewの配列
    override func getUITextViews() -> [UITextView] {
        return [self.noteTextView]
    }

    /// 画像選択プロトコル拡張に対してイメージビューを戻す。
    ///
    /// - Returns: イメージビュー
    func get() -> UIImageView {
        return self.wineImageView
    }
    
    /// 画像選択プロトコル拡張に対して画像選択状態を戻す。
    ///
    /// - Returns: 画像選択状態
    func get() -> SelectableImageStatus {
        return self.imageStatus
    }
    
    /// 画像選択プロトコル拡張の画像の選択状態管理用プロパティーの設定
    ///
    /// - Parameter selectableImageStatus: 画像選択状態
    func set(selectableImageStatus:SelectableImageStatus) {
        self.imageStatus = selectableImageStatus
    }
    
    /// didReceiveMemoryWarning
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// viewWillAppear
    ///
    /// - Parameter animated: <#animated description#>
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
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

    /// ヴィンテージリストの作成
    ///
    func initVintageList(){
        let now = Date()
        // システムのカレンダーを取得
        let cal = Calendar.current
        
        // 現在時刻のDateComponentsを取り出す
        var dateComps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        let nowYear = dateComps.year!
        let startYear = nowYear - Settings.instance.vintageRange
        self.vintageList.removeAll()
        for year in startYear...nowYear {
            self.vintageList.append(String(year))
        }
    }
    
    /// PickerViewの列数
    ///
    /// - Parameter pickerView: ヴィンテージピッカービュー
    /// - Returns: ヴィンテージピッカービューの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /// PickerViewの行数
    ///
    /// - Parameters:
    ///   - pickerView: ヴィンテージピッカービュー
    ///   - component: コンポーネント番号
    /// - Returns: ヴィンテージピッカービューの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return vintageList.count
    }
    
    /// PickerViewの要素
    ///
    /// - Parameters:
    ///   - pickerView: ヴィンテージピッカービュー
    ///   - row: 行番号
    ///   - component: コンポーネント番号
    /// - Returns: ヴィンテージピッカービューの要素
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return vintageList[row]
    }
    
    /// PickerView選択時
    ///
    /// - Parameters:
    ///   - pickerView: ヴィンテージピッカービュー
    ///   - row: 行番号
    ///   - component: コンポーネント番号
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.vintageTextField.text = vintageList[row]
    }
    
    /// PickerViewのdoneボタン
    ///
    func done() {
        self.vintageTextField.endEditing(true)
    }
    
    /// PickerViewのcancelボタン
    ///
    func cancel() {
        self.vintageTextField.text = ""
        self.vintageTextField.endEditing(true)
    }
    
    /// タイトル
    /// SelectableImageで表示するアラートのタイトルを設定する。
    ///
    /// - Returns: タイトル
    func titleForSelectableImage() -> String {
        return "ワインの写真"
    }
    
    /// メッセージ
    /// SelectableImageで表示するアラートのメッセージを設定する。
    ///
    /// - Returns: メッセージ
    func messageForSelectableImage() -> String {
        return "写真を選択してください。"
    }
    
    /// 写真ボタン
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func imageSelectTouchUpInside(_ sender: Any) {
        self.selectImageAction()
    }
    
    /// クリアボタン
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func imageClearTouchUpInside(_ sender: Any) {
        self.clearImageAction()
    }

    /// 写真選択時の処理
    ///
    /// - Parameters:
    ///   - picker: ピッカーコントローラー
    ///   - info: メディア情報
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // プロトコル拡張のメソッドに処理を委譲する。
        self.imagePickerControllerAction(picker, didFinishPickingMediaWithInfo: info)
    }

    /// バリデーション
    ///
    /// - Returns: true:成功 false:失敗
    func validate() -> Bool {
        var valid = true
        valid = self.nameTextField.requiredCheck()
        if !valid {
            self.showInvalidMessage(message: "名前を入力してください。")
        }
        return valid
    }
    
    /// 保存ボタン
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func saveTouchUpInside(_ sender: Any) {
        self.saveAction(
            handler: {
                (action: UIAlertAction!) -> Void in
                if self.validate() {
                    self.saveWine()
                }
        })
    }

    /// リセットボタン
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func resetTouchUpInside(_ sender: Any) {
        self.resetAction(
            handler: {
                (action: UIAlertAction!) -> Void in
                if self.wine != nil {
                    self.selectedCell(wine: self.wine!)
                }
                else{
                    self.addWine()
                }
                // 完了メッセージ表示
                self.showResetMessage()
        })
    }

    /// マスターテーブルで選択されたワインの更新
    ///
    /// - Parameter wine: マスターテーブルで選択されたワイン
    func selectedCell(wine: Wine) {
        self.title = "ワインの更新"
        
        self.wine = wine
        self.nameTextField.text = wine.name
        self.aliasTextField.text = wine.alias
        self.wineryTextField.text = wine.winery
        self.noteTextView.text = wine.note
        self.vintageTextField.text = String(wine.vintage)
        self.setCategorySegmentedControl(wine: wine)
        self.priceTextField.text = String(wine.price)
        self.priceAskSwitch.isOn = wine.priceAsk
        self.displaySwitch.isOn = wine.display
        if let image = wine.image {
            self.wineImageView.image = UIImage(data: image)
        } else{
            self.wineImageView.image = Settings.instance.defaultImage
        }
        self.imageStatus = SelectableImageStatus.nothing

        // 資料ワーク領域の設定
        self.setMaterialsWork(wine: wine)
        
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
    
    /// 資料のワーク領域の設定
    ///
    /// - Parameter wine: 処理対象のワイン
    func setMaterialsWork(wine:Wine) {
        self.materialsWork.removeAll()
        if let materials = wine.materials {
            for material in materials {
                self.materialsWork.insert(material as! Material)
            }
        }

    }

    /// カテゴリーのセグメントコントロールを選択
    ///
    /// - Parameter wine: カテゴリーのセグメントコントロールを選択する対象のワイン
    func setCategorySegmentedControl(wine: Wine){
        let wineList = self.getWineList()
        let categoryList = wineList.categoryList
        let index = categoryList.index(data: wine.category!)
        self.categorySegmentedControl.selectedSegmentIndex = index
    }

    /// ワインの追加(空画面の生成)
    ///
    func addWine() {
        self.title = "ワインの追加"
        self.wine = nil
        self.materialsWork.removeAll()

        self.nameTextField.text = nil
        self.aliasTextField.text = nil
        self.wineryTextField.text = nil
        self.noteTextView.text = nil
        self.vintageTextField.text = nil
        self.categorySegmentedControl.selectedSegmentIndex = 0
        self.priceTextField.text = String(Settings.instance.defaultPrice)
        self.priceAskSwitch.isOn = false
        self.displaySwitch.isOn = true

        // ワイン画像
        self.wineImageView.image = Settings.instance.defaultImage
        self.imageStatus = SelectableImageStatus.nothing

        self.insertDateLabel.text = nil
        self.updateDateLabel.text = nil
    }

    /// ワインリストの取得
    ///
    /// - Returns: ワインリスト
    func getWineList() -> WineList {
        let detailViewController = self.parent as! DetailViewController
        let wineList = detailViewController.getWineList()
        return wineList
    }

    /// カテゴリーリストの取得
    ///
    /// - Returns: カテゴリーリスト
    func getCategoryList() -> DataList<Category> {
        let wineList = self.getWineList()
        let categoryList = wineList.categoryList
        return categoryList
    }
    
    /// CoreDataへのワインデータ保存
    ///
    func saveWine(){
        let wineList = self.getWineList()

        var wine:Wine
        if self.wine != nil {
            // 更新
            wine = self.wine!
        }
        else {
            // 追加
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
        let categoryList = wineList.categoryList
        let category = categoryList.get(self.categorySegmentedControl.selectedSegmentIndex)
        wine.changeCategory(category)

        // 価格
        let price = self.textFieldToInt32(textField: self.priceTextField)
        wine.price = price
        wine.priceAsk = self.priceAskSwitch.isOn
        
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

        // 資料
        wine.materials = nil
        for material in self.materialsWork {
            wine.addToMaterials(material)
        }

        // 登録日時、更新日時
        let now = Date()
        if wine.insertDate == nil {
            wine.insertDate = now
        }
        wine.updateDate = now

        // 保存
        wineList.save(wine: wine)

        // 完了メッセージ表示
        self.showSaveMessage()

        let detailViewController = self.parent as! DetailViewController
        detailViewController.selectedCell(wine: wine)

        self.reloadWineTableView()
    }
    
    /// テキストフィールドの値をInt16で取得
    /// 整数値に変換できない場合は0を戻す。
    ///
    /// - Parameter textField: テキストフィールド
    /// - Returns: Int16型の数値
    func textFieldToInt16(textField: UITextField) -> Int16 {
        if let str = textField.text {
            if let num = Int16(str) {
                return num
            }
        }
        return 0
    }
    
    /// テキストフィールドの値をInt32で取得
    /// 整数値に変換できない場合は0を戻す。
    ///
    /// - Parameter textField: テキストフィールド
    /// - Returns: Int32型の数値
    func textFieldToInt32(textField: UITextField) -> Int32 {
        if let str = textField.text {
            if let num = Int32(str) {
                return num
            }
        }
        return 0
    }
    
    /// マスターテーブルのリロード
    ///
    func reloadWineTableView(){
        let detailViewController = self.parent as! DetailViewController
        detailViewController.reloadWineTableView()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     */

    /// セグエによる遷移時
    ///
    /// - Parameters:
    ///   - segue: セグエ
    ///   - sender: 送信元
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        // 資料選択ポップアップ
        if segue.identifier == "PopupMaterialSelect" {
            let popupMaterialSelectViewController = segue.destination as! PopupMaterialSelectViewController
            popupMaterialSelectViewController.registrationViewController = self
        }
    }
}
