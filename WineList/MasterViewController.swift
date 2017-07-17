//
//  MasterTableViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/04/12.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit
import CoreData

///
/// MasterViewControllerデリゲート
///
protocol MasterViewControllerDelegate: class {
    //func selectedCell(image: UIImage)
    func selectedCell(wine: Wine)
    func addWine()
    func setManageMode()
    func setReferenceMode()
}

///
/// MasterViewController
///
class MasterViewController: UITableViewController,SettingsDelegate {
    // 設定クラス
    private let settings = Settings.instance

    // 管理モード
    private var manageMode:Bool = false
    
    @IBOutlet var wineTableView: UITableView!
    private let tableData = ["test_morning_sample", "test_evening_sample", "test_night_sample"]

    var delegate: MasterViewControllerDelegate?
    //var wineList:Array<Wine> = []
    // ワインリスト
    private var wineList:WineList

    // TODO:削除
    //var wineDictionary:Dictionary<Category, Array<Wine>> = [:]
    //var wineLinkedList = LinkedList<Wine>()

    // ナビゲーションバーのボタン
    private var addButton:UIBarButtonItem
    private var replyButton:UIBarButtonItem
    private var editButton:UIBarButtonItem

    // 管理モード遷移用の長押し設定
    private var longPressGesture:UILongPressGestureRecognizer
    
    ///
    /// イニシャライザ
    ///
    required init?(coder aDecoder: NSCoder) {
        // WineList
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        self.wineList = WineList(managedObjectContext: viewContext)

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
    ///
    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MasterViewController.viewDidLoad")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        self.title = "リスト"
/********
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        longGesture.minimumPressDuration = 1.0  // default:0.5秒
        longGesture.allowableMovement = 15 // default:10point
        //longGesture.numberOfTapsRequired = 2    // default:0
************/
        
        let titleView = UILabel()
        titleView.text = self.title
        //titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        titleView.sizeToFit()
        //let width = titleView.sizeThatFits(CGSizeMake(CGFloat.max, CGFloat.max)).width
        //titleView.frame = CGRect(origin:CGPointZero, size:CGSizeMake(width, 500))
        titleView.addGestureRecognizer(self.longPressGesture)
        titleView.isUserInteractionEnabled = true
        self.navigationItem.titleView = titleView

        // ワインディクショナリーの初期化
        //self.initWineDictionary()

        // 編集時にセル選択を許可
        self.wineTableView.allowsSelectionDuringEditing = true
        //self.wineTableView.estimatedRowHeight = 20
        //self.wineTableView.rowHeight = UITableViewAutomaticDimension
        
        //self.setReferenceMode()
        
        //navigationItem.leftBarButtonItem = editButtonItem
/***********
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "UIBarButtonCompose_2x_cd7e6340-c981-4dc4-85ae-63ae5a64ccfc"), for: .normal)
        button.frame = CGRect(x:0.0, y:0.0, width:20.0, height:20.0)
        //button.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        longGesture.minimumPressDuration = 1.0  // default:0.5秒
        longGesture.allowableMovement = 15 // default:10point
        longGesture.numberOfTapsRequired = 2    // default:0

        button.addGestureRecognizer(longGesture)
        let manageButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(setManageMode(_:)))
        manageButton.customView = button

        //let manageButtonView = UIView()
        //manageButtonView.frame = CGRect(x:0.0, y:0.0, width:45.0, height:45.0)
        //manageButtonView.backgroundColor = UIColor.clear
        //manageButtonView.alpha = 0.0
        //manageButtonView.addGestureRecognizer(longGesture)
        //manageButton.customView = manageButtonView
        //let manageButtonView:UIView = manageButton.value(forKey: "view") as! UIView
        //manageButtonView.addGestureRecognizer(longGesture)
        //let uiImage = manageButton.backgroundImage(for: .normal, barMetrics: UIBarMetrics.default)
        //button.setImage(uiImage, for: .normal)
        //manageButton.customView?.addGestureRecognizer(longGesture)

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWine(_:)))
        //navigationItem.rightBarButtonItem = addButton
        navigationItem.setRightBarButtonItems([manageButton,addButton], animated: true)
*************/
/********
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        longGesture.minimumPressDuration = 1.0  // default:0.5秒
        longGesture.allowableMovement = 15 // default:10point
        longGesture.numberOfTapsRequired = 2    // default:0

        //
        //self.navigationItem.titleView?.addGestureRecognizer(longGesture)
        //TableView全体に長押し
        //self.wineTableView.addGestureRecognizer(longGesture)
        let titleView = UILabel()
        titleView.text = "リスト"
        //titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        titleView.sizeToFit()
        //let width = titleView.sizeThatFits(CGSizeMake(CGFloat.max, CGFloat.max)).width
        //titleView.frame = CGRect(origin:CGPointZero, size:CGSizeMake(width, 500))
        titleView.addGestureRecognizer(longGesture)
        titleView.isUserInteractionEnabled = true
        self.navigationItem.titleView = titleView
*******/
    }
    ///
    /// 設定変更の反映
    ///
    func changeSettings() {
        /// 管理モードへの遷移用長押し秒数
        let longPressDuration = self.settings.longPressDuration
        self.longPressGesture.minimumPressDuration = longPressDuration
    }
    ///
    /// ワインリストの取得
    ///
    func getWineList() -> WineList{
        return self.wineList
    }
    ///
    /// タイトル長押し時
    ///
    func longTap(_ sender: UIGestureRecognizer) {
        print("logTap")
        if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
            if(self.manageMode){
                self.endManageModeAlert()
            } else {
                self.passwordAlert()
            }
        }
        else if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
        }
    }
    ///
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
                            print("password=" + textField.text!)
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
    ///
    /// パスワードの確認
    ///
    func verify(password: String?) -> Bool{
        if let password = password {
            if password == self.settings.password {
                return true
            }
        }
        return false
    }
    ///
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

    ///
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
    ///
    /// ナビゲーションバーの追加ボタン
    ///
    func addButtonAction(_ sender: Any){
        print("addButtonAction")
        self.addWine()
    }
    ///
    /// ナビゲーションバーのreplyボタン(管理モードの終了)
    ///
    func replyButtonAction(_ sender: Any){
        print("replyButtonAction")
        self.endManageModeAlert()
    }
    ///
    /// ナビゲーションバーのeditボタン
    ///
    func editButtonAction(_ sender: Any){
        print("editButtonAction")
        if (self.wineTableView.isEditing){
            self.wineTableView.setEditing(false, animated: true)
        } else {
            self.wineTableView.setEditing(true, animated: true)
        }
    }
    ///
    /// ワインの追加
    ///
    func addWine() {
        //ディテール部を表示する。
        self.delegate?.addWine()
        //self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.primaryHidden
    }
    ///
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
        //self.getData()
/*********
        self.wineList.getData()
 ***********/
        // 並び順を初期化
        //self.wineList?.initWineOrder()
        // TableViewを再読み込みする
        self.wineTableView.reloadData()
    }
    ///
    /// テーブルのリロード
    ///
    func reloadWineTableView(){
        //self.getData()
        //self.wineList.getData()
        self.wineTableView.reloadData()
    }
    ///
    /// ワインディクショナリーの初期化
    /// todo:メソッド削除
/******
    func initWineDictionary(){
        self.wineDictionary = [:]
        for elem in CategoryEnum.enumerate() {
            let category = elem.element
            let wineArray:Array<Wine> = []
            self.wineDictionary[category] = wineArray
        }
    }
    // ワインディクショナリーへのワインの追加
    // todo:メソッド削除
    func appendWineDictionary(wine: Wine){
        let category = CategoryEnum.init(raw: Int(wine.category))
        var wineArray = self.wineDictionary[category!]
        wineArray?.append(wine)
        self.wineDictionary.updateValue(wineArray!, forKey: category!)
    }
    // todo:メソッド削除
    func getData() {
        //self.wineList = []
        self.initWineDictionary()

        // データ保存時と同様にcontextを定義
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        // CoreDataからデータをfetchしてtasksに格納
        let fetchRequest: NSFetchRequest<Wine> = Wine.fetchRequest()
        do {
            let fetchData = try viewContext.fetch(fetchRequest)
            for wine in fetchData {
                //                let wine = Wine(context: viewContext)
                //                wine.name = data.name
                //                wine.note = data.note
                //                wine.color = data.color
                //                wine.vintage = data.vintage
                //self.wineList.append(wine)
                self.appendWineDictionary(wine: wine)
                self.wineLinkedList.append(value: wine)
            }
        } catch {
            print("Fetching Failed.")
        }
        // LinkedListの確認用
        self.linkedListTest()
        self.printLinkedList()
    }
    /// LinkedListのテスト
    func linkedListTest(){
        let list = LinkedList<Int>()
        list.append(value: 1)
        list.append(value: 2)
        list.append(value: 3)
        for num in list {
            print("\(num)")
        }
    }
    /// LinkedListの確認用
    func printLinkedList(){
        for wine in self.wineLinkedList{
            print("\(wine)")
        }
        let count = self.wineLinkedList.count
        for i in 0..<count {
            let wine = self.wineLinkedList.nodeAt(index: i)
            print("\(wine)")
        }
    }
***********/
    ///
    /// カテゴリーリストの取得
    ///
    func getCategoryList() -> DataList<Category> {
        let wineList = self.getWineList()
        let categoryList = wineList.categoryList
        return categoryList
    }
    ///
    /// カテゴリーの取得
    ///
    func getCategory(_ row: Int) -> Category {
        let categoryList = self.getCategoryList()
        let category = categoryList.get(row)
        return category
    }
    
    // MARK: - Table view data source

    ///
    /// テーブルビューのセクション数
    ///
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let categoryList = self.getCategoryList()
        let count = categoryList.count()
        return count
        //return CategoryEnum.count
    }
    ///
    /// テーブルビューのセクションデータ
    ///
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let category = CategoryEnum.init(raw: section)
//        return category?.description
        let category = self.getCategory(section)
        return category.name
    }
    ///
    /// テーブルビューのデータの個数を返すメソッド
    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.wineList.count
        //let category = CategoryEnum.init(raw: section)
        let category = self.getCategory(section)
        //let wineArray = self.wineDictionary[category!]
        //let count = wineArray?.count
        let count = self.wineList.count(category)
        return count
    }
    ///
    /// データを返すメソッド
    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let category = CategoryEnum.init(raw: indexPath.section)
        let category = self.getCategory(indexPath.section)
        //let wineArray = self.wineDictionary[category!]
        
        //セルを取得し、テキストを設定して返す。
        let cell = tableView.dequeueReusableCell(withIdentifier: "WineCell", for: indexPath)
        //let wine = wineArray?[indexPath.row]
        //let wine = self.wineList[indexPath.row]
        let wine = self.wineList.getWine(category, indexPath.row)
//        cell.textLabel?.text = wine.name
//        cell.detailTextLabel?.text = NumberUtil.japanesePrice(price: Int(wine.price))
        let imageView = cell.viewWithTag(1) as! UIImageView
        let nameLabel = cell.viewWithTag(2) as! UILabel
        let priceLabel = cell.viewWithTag(3) as! UILabel
        nameLabel.text = wine.name
        priceLabel.text = NumberUtil.japanesePrice(price: Int(wine.price))
        if let image = wine.image {
            imageView.image = UIImage(data: image)

            //cell.imageView?.image = UIImage(data: image)
            //let size = CGSize(width:30,height:30)
            //cell.imageView?.image = UIImage(data: image)?.resize(size: size)
            //cell.imageView?.contentMode = .scaleAspectFill
        }
        if(!(wine.display)){
            //UIColor.blue2は、Extentionで作成したカスタムカラー
            //cell.backgroundColor = UIColor.blue2
            cell.textLabel?.textColor = UIColor.blue2
            //if(self.isReferenceMode()){
                // hiddenにするだけだと、高さが詰まらない。
                //cell.isHidden = true
                //cell.frame.size = CGSize(width:0, height:0)
                //cell.sizeToFit()
            //}
        } else {
            cell.textLabel?.textColor = nil
        }
        return cell
    }
    ///
    /// 管理モード判定
    ///
    func isManageMode() -> Bool{
        return self.manageMode
    }
    ///
    /// 参照モード判定
    ///
    func isReferenceMode() -> Bool{
        return !self.manageMode
    }
    ///
    /// データ選択後の呼び出しメソッド
    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let category = CategoryEnum.init(raw: indexPath.section)
        let category = self.getCategory(indexPath.section)
        //let wineArray = self.wineDictionary[category!]
        //let wine = wineArray?[indexPath.row]
        let wine = self.wineList.getWine(category, indexPath.row)
        self.delegate?.selectedCell(wine: wine)
        //todo
//        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
//            //デリゲートメソッドを呼び出す。
//            self.delegate?.selectedCell(wine: self.wineList[selectedRowIndexPath.row])
//        }
        
        if let detailViewController = self.delegate as? DetailViewController {
            //ディテール部を表示する。
            splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
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
            print("editingStyle=delete")
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
            //let category = CategoryEnum.init(raw: indexPath.section)
            let category = self.getCategory(indexPath.section)
//            var wineArray = self.wineDictionary[category!]
//            wineArray?.remove(at: indexPath.row)
            self.wineList.delete(category, indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            //tableView.reloadData()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            print("editingStyle=insert")
        }
    }

    ///
    /// 並び替え
    ///
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        print("moveRowAt")
        //let fromCategory = CategoryEnum.init(raw: fromIndexPath.section)
        let fromCategory = self.getCategory(fromIndexPath.section)
        let wine = self.wineList.getWine(fromCategory, fromIndexPath.row)
        //print("from category=" + (fromCategory?.description)! + " name=" + (wine.name)!)

        //let toCategory = CategoryEnum.init(raw: to.section)
        let toCategory = self.getCategory(to.section)
        self.wineList.moveRow(wine: wine, toCategory: toCategory, toRow: to.row)
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
