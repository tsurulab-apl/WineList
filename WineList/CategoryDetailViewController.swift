//
//  CategoryDetailViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/06/20.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

class CategoryDetailViewController: UIViewController,CategoryMasterViewControllerDelegate {
    //
    private var category:Category?

    // サブビュー
    private var categoryRegistrationViewController:CategoryRegistrationViewController? = nil

    // ナビゲーションバーボタン
    private var doneButton:UIBarButtonItem

    //
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var insertDateLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!

    // マスタービューコントローラー
    var categoryMasterViewController:CategoryMasterViewController {
        let masterNavController = self.splitViewController?.viewControllers.first as! UINavigationController
        let categoryMasterViewController = masterNavController.topViewController as! CategoryMasterViewController
        return categoryMasterViewController
    }

    ///
    /// イニシャライザ
    ///
    required init?(coder aDecoder: NSCoder) {
        // BarButton
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        
        super.init(coder: aDecoder)
        // super.initの後にselfを設定可能
        self.doneButton.target = self
        self.doneButton.action = #selector(doneButtonAction(_:))
    }

    ///
    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "カテゴリーの登録"

        //ナビゲーションバーの左ボタンに画面モードの切り替えボタンを表示する。
        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        
        //戻るボタンの後ろに表示する。
        self.navigationItem.leftItemsSupplementBackButton = true

        // ナビゲーションバーボタンの作成
        self.navigationItem.setRightBarButtonItems([self.doneButton], animated: true)

        //サブビュー
        self.categoryRegistrationViewController = self.storyboard?.instantiateViewController(withIdentifier: "categoryRegistrationViewController") as? CategoryRegistrationViewController
        self.addChildViewController(self.categoryRegistrationViewController!)
        self.view.addSubview((self.categoryRegistrationViewController?.view)!)
        self.categoryRegistrationViewController?.view.isHidden = true
    }

    ///
    /// didReceiveMemoryWarning
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    ///
    /// ナビゲーションバーのDoneボタン
    ///
    func doneButtonAction(_ sender: Any){
        print("doneButtonAction")
        //self.categoryRegistrationViewController?.save()
        self.dismiss(animated: true, completion: nil)
//        let mainStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let initialViewController:UIViewController = mainStoryBoard.instantiateInitialViewController()!
//        self.present(initialViewController, animated: true, completion: nil)
    }
    ///
    /// テーブルビューのリロード
    ///
    func reloadCategoryTableView(){
        self.categoryMasterViewController.reloadCategoryTableView()
    }
    ///
    /// カテゴリーリストの取得
    ///
    func getCategoryList() -> DataList<Category> {
        let categoryList = self.categoryMasterViewController.getCategoryList()
        return categoryList
    }

    ///
    /// セル選択時(delegate)
    ///
    func selectedCell(category: Category) {
        self.category = category
        self.categoryRegistrationViewController?.selectedCell(category: category)
        self.changeScreen()
    }
    
    ///
    /// カテゴリーの追加(delegate)
    ///
    func addCategory() {
        self.categoryRegistrationViewController?.addCategory()
        
        // 画面が出ていない場合(カテゴリーを選択していない状態)もあるため、画面の切り替えを実施する。
        self.categoryRegistrationViewController?.view.isHidden = false
    }

    ///
    /// 画面の切り替え
    ///
    func changeScreen(){
        if self.category != nil {
            self.categoryRegistrationViewController?.view.isHidden = false
        } else {
            self.categoryRegistrationViewController?.view.isHidden = true
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
