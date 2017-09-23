//
//  MasterTableViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/04/12.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit
import CoreData

/// MasterViewControllerデリゲート
///
protocol MasterViewControllerDelegate: class {
    func selectedCell(wine: Wine)
    func addWine()
    func setManageMode()
    func setReferenceMode()
    func delete(wine: Wine)
}

/// ワインマスターテーブルビュー画面
///
class MasterViewController: UITableViewController,SettingsDelegate {
    /// 設定クラス
    private let settings = Settings.instance

    /// 管理モード
    private var manageMode:Bool = false

    // コントロール
    @IBOutlet var wineTableView: UITableView!

    /// デリゲート
    var delegate: MasterViewControllerDelegate?

    /// ワインリスト
    private var wineList:WineList

    // ナビゲーションバーのボタン

    /// 追加ボタン
    private var addButton:UIBarButtonItem

    /// 管理モードから戻るボタン
    private var replyButton:UIBarButtonItem

    /// Editボタン
    private var editButton:UIBarButtonItem

    /// 管理モード遷移用の長押し設定
    private var longPressGesture:UILongPressGestureRecognizer
    
    /// イニシャライザ
    ///
    required init?(coder aDecoder: NSCoder) {
        // WineList
        self.wineList = ApplicationContext.instance.wineList

        // BarButton
        self.addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        self.replyButton = UIBarButtonItem(barButtonSystemItem: .reply, target: nil, action: nil)
        self.editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)

        // 管理モード遷移用の長押し設定
        self.longPressGesture = UILongPressGestureRecognizer()

        super.init(coder: aDecoder)

        // ----------------------------
        // super.iniの後にselfを設定可能
        // ----------------------------

        // 設定変更時の通知先設定
        self.settings.set(delegate: self)

        // BarButtonの設定
        self.addButton.target = self
        self.addButton.action = #selector(addButtonAction(_:))
        self.replyButton.target = self
        self.replyButton.action = #selector(replyButtonAction(_:))
        self.editButton.target = self
        self.editButton.action = #selector(editButtonAction(_:))
        
        // 管理モード遷移用の長押し設定
        self.longPressGesture.addTarget(self, action: #selector(longTap(_:)))
        self.longPressGesture.minimumPressDuration = self.settings.longPressDuration // default:0.5秒
        self.longPressGesture.allowableMovement = 15  //default:10point
        //self.longPressGesture.numberOfTapsRequired = 2 // default:0
        
        // WineListの並び順設定
        // 並び順が設定できなかった際にコメントを外して実行する。
        //self.wineList.initWineOrder()
    }

    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        self.title = "リスト"

        // delegateの設定
        let detailNavController = self.splitViewController?.viewControllers.last as! UINavigationController
        let DetailViewController = detailNavController.topViewController as! DetailViewController
        self.delegate = DetailViewController
        
        //ナビゲーションバーの左ボタンに画面モードの切り替えボタンを表示する。
        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        
        //戻るボタンの後ろに表示する。
        self.navigationItem.leftItemsSupplementBackButton = true

        let titleView = UILabel()
        titleView.text = self.title
        //titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        titleView.sizeToFit()
        //let width = titleView.sizeThatFits(CGSizeMake(CGFloat.max, CGFloat.max)).width
        //titleView.frame = CGRect(origin:CGPointZero, size:CGSizeMake(width, 500))
        titleView.addGestureRecognizer(self.longPressGesture)
        titleView.isUserInteractionEnabled = true
        self.navigationItem.titleView = titleView

        // 編集時にセル選択を許可
        self.wineTableView.allowsSelectionDuringEditing = true
    }

    /// 設定変更の反映
    ///
    func changeSettings() {
        /// 管理モードへの遷移用長押し秒数
        let longPressDuration = self.settings.longPressDuration
        self.longPressGesture.minimumPressDuration = longPressDuration

        // 価格問合せ文字変更時にテーブルビューのリロード
        self.reloadWineTableView()
    }
    
    /// ワインリストの取得
    ///
    /// - Returns: ワインリスト
    func getWineList() -> WineList{
        return self.wineList
    }
    
    /// タイトル長押し時
    ///
    /// - Parameter sender: <#sender description#>
    func longTap(_ sender: UIGestureRecognizer) {
        //print("logTap")
        if sender.state == .began {
            //print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
            if(self.manageMode){
                self.endManageModeAlert()
            } else {
                self.passwordAlert()
            }
        }
        else if sender.state == .ended {
            //print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
        }
    }
    
    /// 管理モード移行時のパスワード認証
    ///
    func passwordAlert(){
        let alert = UIAlertController( title:"パスワード", message: "入力してください",
                                       preferredStyle: UIAlertControllerStyle.alert)

        alert.addTextField( configurationHandler: { (passwordTextField: UITextField!) -> Void in
            passwordTextField.isSecureTextEntry = true
            passwordTextField.keyboardType = UIKeyboardType.numberPad
        })
        alert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                
                let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                if textFields != nil {
                    for textField:UITextField in textFields! {
                        // isSecureTextEntryの状態で判定
                        if textField.isSecureTextEntry == true {
                            // パスワード表示
                            //print("password=" + textField.text!)
                            if self.verify(password: textField.text) {
                                self.setManageMode()
                            } else {
                                // 再表示
                                self.passwordAlert()
                            }
                        }
                    }
                }
            })
        )
        
        alert.addAction( UIAlertAction(title: "Cancel", style: .cancel) {
            action in
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    /// パスワードの確認
    ///
    /// - Parameter password: パスワード
    /// - Returns: 確認結果 true:一致 false:不一致
    func verify(password: String?) -> Bool{
        if let password = password {
            if password == self.settings.password {
                return true
            }
        }
        return false
    }
    
    /// 管理モード終了時のパスワード認証
    ///
    func endManageModeAlert(){
        let alert = UIAlertController( title:"確認", message: "管理モードを終了します。よろしいですか？",
                                       preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                self.setReferenceMode()
            })
        )
        
        alert.addAction( UIAlertAction(title: "Cancel", style: .cancel) {
            action in
        })
        
        present(alert, animated: true, completion: nil)
    }

    /// 管理モードへの変更
    ///
    func setManageMode(){
        self.manageMode = true
        self.navigationItem.setRightBarButtonItems([self.addButton, self.replyButton, self.editButton], animated: true)

        // WineList
        self.wineList.setManageMode()
        
        // reload
        self.reloadWineTableView()

        // DetailViewを管理モードに変更
        self.delegate?.setManageMode()
    }
    
    /// ナビゲーションバーの追加ボタン
    ///
    /// - Parameter sender: <#sender description#>
    func addButtonAction(_ sender: Any){
        //print("addButtonAction")
        self.addWine()
    }
    
    /// ナビゲーションバーのreplyボタン(管理モードの終了)
    ///
    /// - Parameter sender: <#sender description#>
    func replyButtonAction(_ sender: Any){
        //print("replyButtonAction")
        self.endManageModeAlert()
    }
    
    /// ナビゲーションバーのeditボタン
    ///
    /// - Parameter sender: <#sender description#>
    func editButtonAction(_ sender: Any){
        //print("editButtonAction")
        if (self.wineTableView.isEditing){
            self.wineTableView.setEditing(false, animated: true)
        } else {
            self.wineTableView.setEditing(true, animated: true)
        }
    }
    
    /// ワインの追加
    ///
    func addWine() {
        //ディテール部を表示する。
        self.delegate?.addWine()
        //self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.primaryHidden
    }
    
    /// 参照モードへの変更
    ///
    func setReferenceMode(){
        self.manageMode = false
        self.navigationItem.setRightBarButtonItems(nil, animated: true)
        
        // WineList
        self.wineList.setReferenceMode()

        // 編集モードを終了
        self.wineTableView.setEditing(false, animated: true)
        
        // reload
        self.reloadWineTableView()
 
        // DetailViewを参照モードに変更
        self.delegate?.setReferenceMode()
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
        //self.getData()
        // TableViewを再読み込みする
        self.wineTableView.reloadData()
    }
    
    /// テーブルのリロード
    ///
    func reloadWineTableView() {
        self.wineTableView.reloadData()
    }
    
    /// カテゴリーリストの取得
    ///
    /// - Returns: カテゴリーリスト
    func getCategoryList() -> DataList<Category> {
        let wineList = self.getWineList()
        let categoryList = wineList.categoryList
        return categoryList
    }
    
    /// カテゴリーの取得
    ///
    /// - Parameter row: カテゴリーリストの行番号
    /// - Returns: カテゴリー
    func getCategory(_ row: Int) -> Category {
        let categoryList = self.getCategoryList()
        let category = categoryList.get(row)
        return category
    }
    
    // MARK: - Table view data source

    /// テーブルビューのセクション数
    ///
    /// - Parameter tableView: テーブルビュー
    /// - Returns: セクション数
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let categoryList = self.getCategoryList()
        let count = categoryList.count()
        return count
    }

    /// テーブルビューのセクションデータ
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - section: セクション番号
    /// - Returns: セクションデータ(カテゴリーの名前)
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let category = self.getCategory(section)
        return category.name
    }

    /// テーブルビューのデータの個数を返すメソッド
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - section: セクション番号
    /// - Returns: セクション(カテゴリー)内のデータ個数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = self.getCategory(section)
        let count = self.wineList.count(category)
        return count
    }

    /// データを返すメソッド
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - indexPath: インデックスパス
    /// - Returns: ワインセル
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = self.getCategory(indexPath.section)
        
        // セルを取得し、テキストを設定して返す。
        let cell = tableView.dequeueReusableCell(withIdentifier: "WineCell", for: indexPath) as! WineTableViewCell

        // セルの再利用時に前の値を削除する。
        cell.clear()
        
        let wine = self.wineList.getWine(category, indexPath.row)
        
        // 名前
        #if (!arch(i386) && !arch(x86_64))
            // 実機
            cell.nameLabel.text = wine.name
        #else
            // シュミレータの場合、ラベルが横にはみ出る問題に対応(スクリーンショットを撮るため)
            cell.nameLabel.text = "   " + wine.name!
        #endif

        // 価格
        if wine.priceAsk {
            cell.priceLabel.text = self.settings.priceAsk
        } else {
            cell.priceLabel.text = NumberUtil.japanesePrice(price: Int(wine.price))
        }

        // 画像
        if let image = wine.image {
            cell.wineImageView.image = UIImage(data: image)
        } else {
            cell.wineImageView.image = self.settings.defaultImage
        }
        if(!(wine.display)){
            //UIColor.blue2は、Extentionで作成したカスタムカラー
            cell.nameLabel.textColor = UIColor.blue2
            cell.priceLabel.textColor = UIColor.blue2
        } else {
            cell.nameLabel.textColor = nil
            cell.priceLabel.textColor = nil
        }
        return cell
    }
    
    /// 管理モード判定
    ///
    /// - Returns: true:管理モード false:参照モード
    func isManageMode() -> Bool{
        return self.manageMode
    }
    
    /// 参照モード判定
    ///
    /// - Returns: true:参照モード false:管理モード
    func isReferenceMode() -> Bool{
        return !self.manageMode
    }
    
    /// データ選択後の呼び出しメソッド
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - indexPath: インデックスパス
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = self.getCategory(indexPath.section)
        let wine = self.wineList.getWine(category, indexPath.row)
        self.delegate?.selectedCell(wine: wine)
        
        if let detailViewController = self.delegate as? DetailViewController {
            //ディテール部を表示する。
            splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
        }
    }

    /// editの有効化
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - indexPath: インデックスパス
    /// - Returns: true:管理モードの場合edit可 false:参照モードの場合edit不可
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        let isEdit = self.isManageMode()
        return isEdit
    }

    /// 削除処理
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - editingStyle: 編集スタイル
    ///   - indexPath: インデックスパス
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let category = self.getCategory(indexPath.section)
            let wine = self.wineList.getWine(category, indexPath.row)
            self.wineList.delete(category, indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            self.delegate?.delete(wine: wine)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    /// 並び替え
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - fromIndexPath: 移動前のインデックスパス
    ///   - to: 移動先のインデックスパス
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let fromCategory = self.getCategory(fromIndexPath.section)
        let wine = self.wineList.getWine(fromCategory, fromIndexPath.row)
        //print("from category=" + (fromCategory?.description)! + " name=" + (wine.name)!)

        let toCategory = self.getCategory(to.section)
        self.wineList.moveRow(wine: wine, toCategory: toCategory, toRow: to.row)
    }

    /// 並び替えの有効化
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - indexPath: インデックスパス
    /// - Returns: true:並び替えを有効化
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
