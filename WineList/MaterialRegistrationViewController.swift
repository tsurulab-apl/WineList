//
//  MaterialRegistrationViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/07/23.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

/// 資料登録画面
///
class MaterialRegistrationViewController: AbstractRegistrationViewController,SelectableImage {

    /// 処理中の資料オブジェクト
    private var material:Material?

    /// 新規追加時の画像
    let newImage = UIImage(named: "NowPrinting")!
    
    /// 資料画像の状態
    var imageStatus = SelectableImageStatus.nothing

    // コントロール
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var formStackView: UIStackView!
    @IBOutlet weak var materialImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var materialTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var insertDateLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!

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

    /// didReceiveMemoryWarning
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return [self.nameTextField]
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
        return self.materialImageView
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
    
    /// タイプの初期化
    ///
    func initMaterialType() {
        self.materialTypeSegmentedControl.removeAllSegments()
        var i = 0
        for elem in MaterialType.enumerate() {
            let materialType = elem.element
            self.materialTypeSegmentedControl.insertSegment(withTitle: materialType.description, at: i, animated: true)
            i += 1
        }
        self.materialTypeSegmentedControl.sizeToFit()
    }
    
    /// viewWillAppear
    ///
    /// - Parameter animated: <#animated description#>
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    /// CoreDataへの資料データ保存
    ///
    func save() {
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

        // 画像
        switch self.imageStatus {
        case SelectableImageStatus.selected:
            let image = self.materialImageView.image
            material.data = image?.jpegData
            break
        case SelectableImageStatus.cleared:
            material.data = nil
            break
        default:
            // 保存しない。
            break
        }

        let now = Date()
        if material.insertDate == nil {
            material.insertDate = now
        }
        material.updateDate = now
        materialList.save(data: material)

        // 完了メッセージ表示
        self.showSaveMessage()
        
        let materialDetailViewController = self.parent as! MaterialDetailViewController
        materialDetailViewController.selectedCell(material: material)
        
        self.reloadMaterialTableView()
    }

    /// 選択されているタイプの取得
    ///
    /// - Returns: 資料タイプ
    func getMaterialTypeSegmentedControl() -> MaterialType {
        let index = self.materialTypeSegmentedControl.selectedSegmentIndex
        if let materialType = MaterialType.init(index: index) {
            return materialType
        }
        return MaterialType.other
    }
    
    /// テーブルビューのリロード
    ///
    func reloadMaterialTableView() {
        let materialDetailViewController = self.parent as! MaterialDetailViewController
        materialDetailViewController.reloadMaterialTableView()
    }
    
    /// 資料リストの取得
    ///
    /// - Returns: 資料リスト
    func getMaterialList() -> DataList<Material> {
        let materialDetailViewController = self.parent as! MaterialDetailViewController
        let materialList = materialDetailViewController.getMaterialList()
        return materialList
    }
    
    /// セル選択時(delegate)
    ///
    /// - Parameter material: マスタービューで選択された資料
    func selectedCell(material: Material) {
        self.material = material
        self.nameTextField.text = material.name
        self.setMaterialTypeSegmentedControl(material: material)
        self.noteTextView.text = material.note
        if let image = material.data {
            self.materialImageView.image = UIImage(data: image)
        } else {
            self.materialImageView.image = self.newImage
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

    /// 資料タイプのセグメントコントロールを選択
    ///
    /// - Parameter material: セグメントコントロールを選択する対象の資料
    func setMaterialTypeSegmentedControl(material: Material) {
        var index = 0
        if let materialType = MaterialType.init(raw: material.type) {
            index = materialType.index
        }
        self.materialTypeSegmentedControl.selectedSegmentIndex = index
    }
    
    /// 資料の追加(delegate)
    ///
    func addMaterial() {
        self.material = nil
        self.materialImageView.image = self.newImage
        self.nameTextField.text = nil
        self.materialTypeSegmentedControl.selectedSegmentIndex = 0
        self.noteTextView.text = nil
        self.insertDateLabel.text = nil
        self.updateDateLabel.text = nil
    }

    /// タイトル
    /// SelectableImageで表示するアラートのタイトルを設定する。
    ///
    /// - Returns: タイトル
    func titleForSelectableImage() -> String {
        return "資料の画像"
    }
    
    /// メッセージ
    /// SelectableImageで表示するアラートのメッセージを設定する。
    ///
    /// - Returns: メッセージ
    func messageForSelectableImage() -> String {
        return "画像を選択してください。"
    }

    /// 画像ボタン
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func imageSelectTouchUpInside(_ sender: Any) {
        self.selectImageAction()
    }

    /// クリアボタン
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func imageClearTouchUpInside(_ sender: Any) {
        self.clearImageAction(defaultImage: self.newImage)
    }

    /// 画像選択時の処理
    ///
    /// - Parameters:
    ///   - picker: <#picker description#>
    ///   - info: <#info description#>
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
    @IBAction func saveButtonTouchUpInside(_ sender: Any) {
        self.saveAction(
            handler: {
                (action: UIAlertAction!) -> Void in
                if self.validate() {
                    self.save()
                }
        })
    }

    /// リセットボタン
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func resetButtonTouchUpInside(_ sender: Any) {
        self.resetAction(
            handler: {
                (action: UIAlertAction!) -> Void in
                if self.material != nil {
                    self.selectedCell(material: self.material!)
                }
                else{
                    self.addMaterial()
                }
                // 完了メッセージ表示
                self.showResetMessage()
        })
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
