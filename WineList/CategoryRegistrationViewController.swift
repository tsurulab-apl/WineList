//
//  CategoryRegistrationViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/06/21.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

class CategoryRegistrationViewController: AbstractRegistrationViewController {
    // カテゴリー
    private var category:Category?

    // コントロール
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var insertDateLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!

    ///
    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    ///
    /// スクロールビューを戻す。
    ///
    override func getScrollView() -> UIScrollView {
        return self.mainScrollView
    }
    
    ///
    /// delegate設定するUITextFiledの配列を戻す。
    ///
    override func getUITextFields() -> [UITextField] {
        return [self.nameTextField]
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
    }
    ///
    /// CoreDataへのカテゴリーデータ保存
    ///
    func save(){
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

        let categoryDetailViewController = self.parent as! CategoryDetailViewController
        categoryDetailViewController.selectedCell(category: category)
        
        self.reloadCategoryTableView()
    }

    ///
    /// テーブルビューのリロード
    ///
    func reloadCategoryTableView(){
        let categoryDetailViewController = self.parent as! CategoryDetailViewController
        categoryDetailViewController.reloadCategoryTableView()
    }

    ///
    /// カテゴリーリストの取得
    ///
    func getCategoryList() -> DataList<Category> {
        let categoryDetailViewController = self.parent as! CategoryDetailViewController
        let categoryList = categoryDetailViewController.getCategoryList()
        return categoryList
    }
    
    ///
    /// セル選択時(delegate)
    ///
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

    ///
    /// カテゴリーの追加(delegate)
    ///
    func addCategory() {
        self.category = nil
        self.nameTextField.text = nil
        self.insertDateLabel.text = nil
        self.updateDateLabel.text = nil
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
        if self.category != nil {
            self.selectedCell(category: self.category!)
        }
        else{
            self.addCategory()
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
