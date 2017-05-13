//
//  MasterTableViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/04/12.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit
import CoreData

//デリゲート
protocol MasterViewControllerDelegate: class {
    //func selectedCell(image: UIImage)
    func selectedCell(wine: Wine)
    func addWine()
    func setManageMode()
}

class MasterViewController: UITableViewController {
    @IBOutlet var wineTableView: UITableView!
    private let tableData = ["test_morning_sample", "test_evening_sample", "test_night_sample"]

    var delegate: MasterViewControllerDelegate?
    var wineList:Array<Wine> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = "リスト"
        
        //navigationItem.leftBarButtonItem = editButtonItem

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

    }
    func addWine(_ sender: Any) {
        //ディテール部を表示する。
        self.delegate?.addWine()
        //self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.primaryHidden
    }
    func setManageMode(_ sender: Any) {
        print("setManageMode")
        self.delegate?.setManageMode()
    }
    func longTap(_ sender: UIGestureRecognizer) {
        print("logTap")
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
    override func viewWillAppear(_ animated: Bool) {
        // CoreDataからデータをfetchしてくる
        getData()
        // TableViewを再読み込みする
        self.wineTableView.reloadData()
    }
    func reloadWineTableView(){
        self.getData()
        self.wineTableView.reloadData()
    }
    func getData() {
        self.wineList = []
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
                self.wineList.append(wine)
            }
        } catch {
            print("Fetching Failed.")
        }
    }
    //データの個数を返すメソッド
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return tableData.count
        return self.wineList.count
    }

    //データを返すメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを取得し、テキストを設定して返す。
        let cell = tableView.dequeueReusableCell(withIdentifier: "WineCell", for: indexPath)
//        cell.textLabel?.text = tableData[indexPath.row]
//        cell.imageView?.image = UIImage(named: tableData[indexPath.row])
        let wine = self.wineList[indexPath.row]
        cell.textLabel?.text = wine.name
        cell.detailTextLabel?.text = wine.note
        return cell
    }

    //データ選択後の呼び出しメソッド
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            //デリゲートメソッドを呼び出す。
            //self.delegate?.selectedCell(image: UIImage(named:tableData[selectedRowIndexPath.row])!)
            self.delegate?.selectedCell(wine: self.wineList[selectedRowIndexPath.row])
        }
        
        if let detailViewController = self.delegate as? DetailViewController {
            //ディテール部を表示する。
            splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
