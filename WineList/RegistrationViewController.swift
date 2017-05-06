//
//  RegistrationViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/05/06.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var vintageTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var wineImageView: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var displaySwitch: UISwitch!

    var pickerView: UIPickerView = UIPickerView()
    var vintageList:[String] = [""]
    let newImageName = "test_morning_sample"

    var wine: Wine? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        print("RegistrationViewController.viewDidLoad")

        self.title = "ワイン"
        
        // カテゴリー
        self.initCategory()
        
        // ヴィンテージのpickerView
        self.initVintagePickerView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // カテゴリーの作成
    func initCategory(){
        self.categorySegmentedControl.removeAllSegments()
        var i = 0
        for elem in Category.enumerate() {
            let category = elem.element
            self.categorySegmentedControl.insertSegment(withTitle: category.description, at: i, animated: true)
            //self.categorySegmentedControl.setTitle(category.description, forSegmentAt: i)
            i += 1
            //print(category)  // White, Red, Rose, Sparkling
        }
        self.categorySegmentedControl.sizeToFit()
    }
    // ヴィンテージピッカービューの作成
    func initVintagePickerView(){
        self.initVintageList()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        let toolbar = UIToolbar(frame: CGRect(x:0.0, y:0.0, width:0.0, height:35.0))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        
        self.vintageTextField.inputView = pickerView
        self.vintageTextField.inputAccessoryView = toolbar
    }
    // ヴィンテージリストの作成
    func initVintageList(){
        let now = Date()
        // システムのカレンダーを取得
        let cal = Calendar.current
        
        // 現在時刻のDateComponentsを取り出す
        var dateComps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        let nowYear = dateComps.year!
        let startYear = nowYear - 50
        for year in startYear...nowYear {
            self.vintageList.append(String(year))
        }
    }
    // PickerViewの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // PickerViewの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return vintageList.count
    }
    // PickerViewの要素
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return vintageList[row]
    }
    // PickerView選択時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.vintageTextField.text = vintageList[row]
    }
    // PickerViewのdoneボタン
    func done() {
        self.vintageTextField.endEditing(true)
    }
    // PickerViewのcancelボタン
    func cancel() {
        self.vintageTextField.text = ""
        self.vintageTextField.endEditing(true)
    }
    // 写真ボタン
    @IBAction func imageSelectTouchUpInside(_ sender: Any) {
        print("imageSelectTouchUpInside")
    }
    // 保存ボタン
    @IBAction func saveTouchUpInside(_ sender: Any) {
        print("saveTouchUpInside")
        // ① UIAlertControllerクラスのインスタンスを生成
        // タイトル, メッセージ, Alertのスタイルを指定する
        // 第3引数のpreferredStyleでアラートの表示スタイルを指定する
        let alert: UIAlertController = UIAlertController(title: "保存", message: "保存してもいいですか？", preferredStyle:  UIAlertControllerStyle.alert)
        
        // ② Actionの設定
        // Action初期化時にタイトル, スタイル, 押された時に実行されるハンドラを指定する
        // 第3引数のUIAlertActionStyleでボタンのスタイルを指定する
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
            self.saveWine()
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
    // リセットボタン
    @IBAction func resetTouchUpInside(_ sender: Any) {
        print("resetTouchUpInside")
    }
    func selectedCell(wine: Wine) {
        self.title = "ワインの更新"
        
        self.wine = wine
        self.nameTextField.text = wine.name
        self.noteTextView.text = wine.note
        self.vintageTextField.text = String(wine.vintage)
        self.categorySegmentedControl.selectedSegmentIndex = Int(wine.category)
        if let image = wine.image {
            self.wineImageView.image = UIImage(data: image)
        }
        else{
            self.wineImageView.image = nil
        }
    }
    func addWine() {
        self.title = "ワインの追加"
        self.wine = nil
        self.nameTextField.text = nil
        self.noteTextView.text = nil
        self.vintageTextField.text = nil
        self.categorySegmentedControl.selectedSegmentIndex = 0
        self.wineImageView.image = UIImage(named: self.newImageName)
    }
    // CoreDataへのワインデータ保存
    func saveWine(){
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        
        //        let entity = NSEntityDescription.entity(forEntityName: "Wine", in: viewContext)
        //        let wine = NSManagedObject(entity:entity!,insertInto:viewContext) as! Wine
        var wine:Wine
        if self.wine != nil {
            // 更新
            wine = self.wine!
        }
        else {
            // 追加
            wine = Wine(context: viewContext)
        }
        wine.name = self.nameTextField.text
        wine.note = self.noteTextView.text
        let vintageStr:String = self.vintageTextField.text!
        let vintage :Int16 = Int16(vintageStr)!
        wine.vintage = vintage
        wine.category = Int16(self.categorySegmentedControl.selectedSegmentIndex)
        
        wine.image = self.wineImageView.image?.jpegData
        do{
            try viewContext.save()
            self.selectedCell(wine: wine)
        }catch{
            print(error)
        }
        self.reloadWineTableView()
    }
    // マスターテーブルのリロード
    func reloadWineTableView(){
        let detailViewController = self.parent
        let masterNavController = detailViewController?.splitViewController?.viewControllers.first as! UINavigationController
        //let masterNavController = self.splitViewController?.viewControllers.first as! UINavigationController
        let masterViewController = masterNavController.topViewController as! MasterViewController
        masterViewController.reloadWineTableView()
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
