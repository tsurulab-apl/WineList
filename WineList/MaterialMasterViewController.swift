//
//  MaterialMasterViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/07/23.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

/// MaterialMasterViewControllerデリゲート
///
protocol MaterialMasterViewControllerDelegate: class {
    func selectedCell(material: Material)
    func addMaterial()
    func delete(material: Material)
}

/// 資料登録マスターテーブルビュー画面
///
class MaterialMasterViewController: UITableViewController,UISplitViewControllerDelegate {
    /// 設定クラス
    private let settings = Settings.instance
    
    // コントロール
    @IBOutlet var materialTableView: UITableView!
    
    /// デリゲート
    var delegate: MaterialMasterViewControllerDelegate?

    /// 資料リスト
    private var materialList:DataList<Material>

    // ナビゲーションバーのボタン

    /// 追加ボタン
    private var addButton:UIBarButtonItem

    /// Editボタン
    private var editButton:UIBarButtonItem

    /// イニシャライザ
    ///
    required init?(coder aDecoder: NSCoder) {
        // MaterialList
        self.materialList = ApplicationContext.instance.wineList.materialList
        
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

    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        // スプリットビュー
        if let split = self.splitViewController {
            split.delegate = self // デリゲートのセット
        }
        
        self.title = "資料"
        
        // delegateの設定
        let detailNavController = self.splitViewController?.viewControllers.last as! UINavigationController
        let materialDetailViewController = detailNavController.topViewController as! MaterialDetailViewController
        self.delegate = materialDetailViewController
        
        // 編集時にセル選択を許可
        self.materialTableView.allowsSelectionDuringEditing = true
        
        //ナビゲーションバーの左ボタンに画面モードの切り替えボタンを表示する。
        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        
        //戻るボタンの後ろに表示する。
        self.navigationItem.leftItemsSupplementBackButton = true
        
        // ナビゲーションボタンの追加
        self.navigationItem.setRightBarButtonItems([self.addButton, self.editButton], animated: true)
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
        // CoreDataからデータをfetchしてくる
        //self.materialList.getData()
        
        // TableViewを再読み込みする
        self.materialTableView.reloadData()
    }

    /// 資料リストの取得
    ///
    /// - Returns: 資料リスト
    func getMaterialList() -> DataList<Material> {
        return self.materialList
    }
    
    /// テーブルのリロード
    ///
    func reloadMaterialTableView() {
        //self.materialList.getData()
        self.materialTableView.reloadData()
    }
    
    /// ナビゲーションバーの追加ボタン
    ///
    /// - Parameter sender: <#sender description#>
    func addButtonAction(_ sender: Any) {
        self.addMaterial()
    }

    /// ナビゲーションバーのeditボタン
    ///
    /// - Parameter sender: <#sender description#>
    func editButtonAction(_ sender: Any) {
        if (self.materialTableView.isEditing){
            self.materialTableView.setEditing(false, animated: true)
        } else {
            self.materialTableView.setEditing(true, animated: true)
        }
    }

    /// カテゴリーの追加
    ///
    func addMaterial() {
        //ディテール部を表示する。
        self.delegate?.addMaterial()
    }

    // MARK: - Table view data source
/*******
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
*******/

    /// テーブルビューのデータの個数を返すメソッド
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - section: セクション番号
    /// - Returns: データの個数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.materialList.count()
    }

    /// データを返すメソッド
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - indexPath: インデックスパス
    /// - Returns: テーブルビューセル
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "materialCell", for: indexPath)
        
        // Configure the cell...
        let material = self.materialList.get(indexPath.row)
        cell.textLabel?.text = material.name
        return cell
    }

    /// データ選択後の呼び出しメソッド
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - indexPath: インデックスパス
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let material = self.materialList.get(indexPath.row)
        self.delegate?.selectedCell(material: material)
        
        if let materialDetailViewController = self.delegate as? MaterialDetailViewController {
            //ディテール部を表示する。
            self.splitViewController?.showDetailViewController(materialDetailViewController.navigationController!, sender: nil)
        }
    }

    /// editの有効化
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - indexPath: インデックスパス
    /// - Returns: true:edit有効
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    /// 削除処理
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - editingStyle: 編集スタイル
    ///   - indexPath: インデックスパス
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let material = self.materialList.get(indexPath.row)
            self.materialList.delete(indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            // 登録画面に削除を通知する。
            self.delegate?.delete(material: material)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    /// 並び替え
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - fromIndexPath: 移動前インデックスパス
    ///   - to: 移動先インデックスパス
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let material = self.materialList.get(fromIndexPath.row)
        self.materialList.moveRow(data: material, toRow: to.row)
    }
    
    /// 並び替えの有効化
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - indexPath: インデックスパス
    /// - Returns: true:並び替え有効
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
