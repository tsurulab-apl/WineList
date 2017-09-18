//
//  CategoryRegistrationViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/06/21.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

/// カテゴリー登録画面
///
class CategoryRegistrationViewController: AbstractRegistrationViewController {
    /// カテゴリー
    private var category:Category?

    // コントロール
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var formStackView: UIStackView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var insertDateLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!

    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /// スクロールビューを戻す。
    ///
    /// - Returns: スクロールビュー
    override func getScrollView() -> UIScrollView {
        return self.mainScrollView
    }
    
    /// スクロールビューでズームするビューを戻す。
    ///
    /// - Returns: ズーム対象ビュー
    override func getZoomView() -> UIView? {
        return self.formStackView
    }

    /// delegate設定するUITextFiledの配列を戻す。
    ///
    /// - Returns: delegate設定するUITextFiledの配列
    override func getUITextFields() -> [UITextField] {
        return [self.nameTextField]
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

    /// CoreDataへのカテゴリーデータ保存
    ///
    func save() {
        let categoryList = self.getCategoryList()
        var category:Category
        if self.category != nil {
            // 更新
            category = self.category!
        }
        else {
            // 追加
            category = categoryList.new()
        }
        category.name = self.nameTextField.text
        
        let now = Date()
        if category.insertDate == nil {
            category.insertDate = now
        }
        category.updateDate = now
        categoryList.save(data: category)

        // 完了メッセージ表示
        self.showSaveMessage()

        let categoryDetailViewController = self.parent as! CategoryDetailViewController
        categoryDetailViewController.selectedCell(category: category)
        
        // DataListの通知機能でマスターテーブルなど必要なビューを更新することもできるが、
        // マスターテーブル内での順序変更や削除時にはマスターテーブルの更新は必要ないため、
        // ここでリロードする。
        self.reloadCategoryTableView()
    }

    /// テーブルビューのリロード
    ///
    func reloadCategoryTableView() {
        let categoryDetailViewController = self.parent as! CategoryDetailViewController
        categoryDetailViewController.reloadCategoryTableView()
    }

    /// カテゴリーリストの取得
    ///
    /// - Returns: カテゴリーリスト
    func getCategoryList() -> DataList<Category> {
        let categoryDetailViewController = self.parent as! CategoryDetailViewController
        let categoryList = categoryDetailViewController.getCategoryList()
        return categoryList
    }
    
    /// セル選択時(delegate)
    ///
    /// - Parameter category: マスタービューで選択されたカテゴリー
    func selectedCell(category: Category) {
        self.category = category
        self.nameTextField.text = category.name
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd' 'HH:mm:ss"
        self.insertDateLabel.text = nil
        if let insertDate = category.insertDate {
            self.insertDateLabel.text = formatter.string(from: insertDate)
        }
        self.updateDateLabel.text = nil
        if let updateDate = category.updateDate {
            self.updateDateLabel.text = formatter.string(from: updateDate)
        }
    }

    /// カテゴリーの追加(delegate)
    ///
    func addCategory() {
        self.category = nil
        self.nameTextField.text = nil
        self.insertDateLabel.text = nil
        self.updateDateLabel.text = nil
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
                if self.category != nil {
                    self.selectedCell(category: self.category!)
                }
                else{
                    self.addCategory()
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
