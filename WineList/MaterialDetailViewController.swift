//
//  MaterialDetailViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/07/23.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

class MaterialDetailViewController: UIViewController,MaterialMasterViewControllerDelegate {
    // 資料
    private var material:Material?
    
    // サブビュー
    private var materialRegistrationViewController:MaterialRegistrationViewController? = nil
    
    // ナビゲーションバーボタン
    private var doneButton:UIBarButtonItem

    // マスタービューコントローラー
    var materialMasterViewController:MaterialMasterViewController {
        let masterNavController = self.splitViewController?.viewControllers.first as! UINavigationController
        let materialMasterViewController = masterNavController.topViewController as! MaterialMasterViewController
        return materialMasterViewController
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
        self.title = "資料の登録"
        
        //ナビゲーションバーの左ボタンに画面モードの切り替えボタンを表示する。
        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        
        //戻るボタンの後ろに表示する。
        self.navigationItem.leftItemsSupplementBackButton = true
        
        // ナビゲーションバーボタンの作成
        self.navigationItem.setRightBarButtonItems([self.doneButton], animated: true)
        
        //サブビュー
        self.materialRegistrationViewController = self.storyboard?.instantiateViewController(withIdentifier: "materialRegistrationViewController") as? MaterialRegistrationViewController
        self.addChildViewController(self.materialRegistrationViewController!)
        self.view.addSubview((self.materialRegistrationViewController?.view)!)
        self.materialRegistrationViewController?.view.isHidden = true
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
        self.dismiss(animated: true, completion: nil)
    }

    ///
    /// テーブルビューのリロード
    ///
    func reloadMaterialTableView(){
        self.materialMasterViewController.reloadMaterialTableView()
    }

    ///
    /// 資料リストの取得
    ///
    func getMaterialList() -> DataList<Material> {
        let materialList = self.materialMasterViewController.getMaterialList()
        return materialList
    }
    
    ///
    /// セル選択時(delegate)
    ///
    func selectedCell(material: Material) {
        self.material = material
        self.materialRegistrationViewController?.selectedCell(material: material)
        self.changeScreen()
    }
    
    ///
    /// 資料の追加(delegate)
    ///
    func addMaterial() {
        self.materialRegistrationViewController?.addMaterial()
        
        // 画面が出ていない場合(カテゴリーを選択していない状態)もあるため、画面の切り替えを実施する。
        self.materialRegistrationViewController?.view.isHidden = false
    }
    
    ///
    /// 画面の切り替え
    ///
    func changeScreen(){
        if self.material != nil {
            self.materialRegistrationViewController?.view.isHidden = false
        } else {
            self.materialRegistrationViewController?.view.isHidden = true
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
