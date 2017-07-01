//
//  CategoryMasterViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/06/20.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit
import CoreData

///
/// CategoryMasterViewControllerデリゲート
///
protocol CategoryMasterViewControllerDelegate: class {
    func selectedCell(category: Category)
    func addCategory()
}
///
///
///
class CategoryMasterViewController: UITableViewController,UISplitViewControllerDelegate {
    private let categoryData = ["White", "Red", "Rose", "Sparkling"]

    // 設定クラス
    private let settings = Settings.instance

    //
    @IBOutlet var categoryTableView: UITableView!

    //
    var delegate: CategoryMasterViewControllerDelegate?

    // カテゴリーリスト
    //private var categoryList:CategoryList
    private var categoryList:DataList<Category>

    // ナビゲーションバーのボタン
    private var addButton:UIBarButtonItem
    private var editButton:UIBarButtonItem
    
    ///
    /// イニシャライザ
    ///
    required init?(coder aDecoder: NSCoder) {
        // CategoryList
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        //self.categoryList = CategoryList(managedObjectContext: viewContext)
        self.categoryList = DataList<Category>(managedObjectContext: viewContext)
        
        // BarButton
        self.addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        self.editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        
        super.init(coder: aDecoder)
        
        // ----------------------------
        // super.iniの後にselfを設定可能
        // ----------------------------
        
        // 設定変更時の通知先設定
        //self.settings.set(delegate: self)
        
        // BarButtonの設定
        self.addButton.target = self
        self.addButton.action = #selector(addButtonAction(_:))
        self.editButton.target = self
        self.editButton.action = #selector(editButtonAction(_:))
    }

    ///
    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()

//        let btn_back = UIBarButtonItem()
//        btn_back.title = "戻る"
//        self.navigationItem.backBarButtonItem = btn_back

        // スプリットビュー
        if let split = self.splitViewController {
            split.delegate = self // デリゲートのセット
        }

        self.title = "カテゴリー"

        // delegateの設定
        let detailNavController = self.splitViewController?.viewControllers.last as! UINavigationController
        let categoryDetailViewController = detailNavController.topViewController as! CategoryDetailViewController
        self.delegate = categoryDetailViewController
        
        // 編集時にセル選択を許可
        self.categoryTableView.allowsSelectionDuringEditing = true

        //ナビゲーションバーの左ボタンに画面モードの切り替えボタンを表示する。
        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        
        //戻るボタンの後ろに表示する。
        self.navigationItem.leftItemsSupplementBackButton = true

        // ナビゲーションボタンの追加
        self.navigationItem.setRightBarButtonItems([self.addButton, self.editButton], animated: true)

    }

    ///
    /// 初期表示をMasterにする。
    ///
//    public func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
//        return true
//    }

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
        // CoreDataからデータをfetchしてくる
        self.categoryList.getData()

        // TableViewを再読み込みする
        self.categoryTableView.reloadData()
    }

    ///
    /// カテゴリーリストの取得
    ///
    func getCategoryList() -> DataList<Category> {
        return self.categoryList
    }
    ///
    /// テーブルのリロード
    ///
    func reloadCategoryTableView(){
        self.categoryList.getData()
        self.categoryTableView.reloadData()
    }

    ///
    /// ナビゲーションバーの追加ボタン
    ///
    func addButtonAction(_ sender: Any){
        print("addButtonAction")
        self.addCategory()
    }
    ///
    /// ナビゲーションバーのeditボタン
    ///
    func editButtonAction(_ sender: Any){
        print("editButtonAction")
        if (self.categoryTableView.isEditing){
            self.categoryTableView.setEditing(false, animated: true)
        } else {
            self.categoryTableView.setEditing(true, animated: true)
        }
    }
    ///
    /// カテゴリーの追加
    ///
    func addCategory() {
        //ディテール部を表示する。
        self.delegate?.addCategory()
    }

    // MARK: - Table view data source
/***
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
***/
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.categoryList.count()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)

        // Configure the cell...
        let category = self.categoryList.get(indexPath.row)
        cell.textLabel?.text = category.name
        return cell
    }
    
    ///
    /// データ選択後の呼び出しメソッド
    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = self.categoryList.get(indexPath.row)
        self.delegate?.selectedCell(category: category)
        
        if let categoryDetailViewController = self.delegate as? CategoryDetailViewController {
            //ディテール部を表示する。
            self.splitViewController?.showDetailViewController(categoryDetailViewController.navigationController!, sender: nil)
        }
    }

    ///
    /// editの有効化
    ///
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    ///
    /// 削除処理
    ///
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.categoryList.delete(indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    ///
    /// 並び替え
    ///
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let category = self.categoryList.get(fromIndexPath.row)
        self.categoryList.moveRow(data: category, toRow: to.row)
    }

    ///
    /// 並び替えの有効化
    ///
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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
