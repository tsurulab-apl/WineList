//
//  CategoryRegistrationViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/06/21.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

class CategoryRegistrationViewController: UIViewController {
    //
    private var category:Category?

    //
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
    /// didReceiveMemoryWarning
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        categoryList.save(category: category)

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
    func getCategoryList() -> CategoryList {
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
