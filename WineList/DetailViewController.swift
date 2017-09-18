//
//  DetailViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/04/12.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

/// ワイン詳細画面
///
class DetailViewController: UIViewController,MasterViewControllerDelegate {

    /// 管理モード
    private var manageMode:Bool = false

    // サブビュー

    /// 参照用ビュー
    private var referenceViewController:ReferenceViewController? = nil

    /// 登録用ビュー
    private var registrationViewController:RegistrationViewController? = nil

    // ナビゲーションバーボタン

    /// 機能選択ボタン
    private var selectButton:UIBarButtonItem

    /// ワイン
    var wine: Wine? = nil

    /// イニシャライザ
    ///
    required init?(coder aDecoder: NSCoder) {
        // BarButton
        self.selectButton = UIBarButtonItem(barButtonSystemItem: .organize, target: nil, action: nil)
        
        super.init(coder: aDecoder)
        // super.initの後にselfを設定可能
        self.selectButton.target = self
        self.selectButton.action = #selector(selectButtonAction(_:))
    }
    
    /// ナビゲーションバーの選択ボタン
    ///
    /// - Parameter sender: <#sender description#>
    func selectButtonAction(_ sender: Any) {
        let alert = UIAlertController(title:"管理メニュー", message: "処理を選択してください。", preferredStyle: UIAlertControllerStyle.alert)
        
        let action1 = UIAlertAction(title: "カテゴリーの登録", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) in
            print("カテゴリーの登録")
            self.categoryButtonAction()
        })
        
        let action2 = UIAlertAction(title: "資料の登録", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) in
            print("資料の登録")
            self.materialButtonAction()
        })

        let action3 = UIAlertAction(title: "設定", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) in
            print("設定")
            self.settingButtonAction()
        })
        
        let cancel = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: {
            (action: UIAlertAction!) in
            print("キャンセル")
        })
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }

    /// ナビゲーションバーのカテゴリーボタン
    ///
    func categoryButtonAction(){
        print("categoryButtonAction")
        let categoryStoryBoard:UIStoryboard = UIStoryboard(name: "Category", bundle: nil)
        let initialViewController = categoryStoryBoard.instantiateInitialViewController()!
        self.present(initialViewController, animated: true, completion: nil)
    }

    /// 資料の登録
    ///
    func materialButtonAction() {
        let materialStoryBoard:UIStoryboard = UIStoryboard(name: "Material", bundle: nil)
        let initialViewController = materialStoryBoard.instantiateInitialViewController()!
        self.present(initialViewController, animated: true, completion: nil)
    }
    
    /// 設定
    ///
    func settingButtonAction() {
        let settingViewController = self.storyboard?.instantiateViewController(withIdentifier: "settingViewController") as! SettingViewController
        self.navigationController?.pushViewController(settingViewController, animated: true)
    }

    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "ワイン"

        //ナビゲーションバーの左ボタンに画面モードの切り替えボタンを表示する。
        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        
        //戻るボタンの後ろに表示する。
        self.navigationItem.leftItemsSupplementBackButton = true

        //サブビュー
        self.referenceViewController = self.storyboard?.instantiateViewController(withIdentifier: "referenceViewController") as? ReferenceViewController
        self.addChildViewController(self.referenceViewController!)
        self.view.addSubview((self.referenceViewController?.view)!)
        self.referenceViewController?.view.isHidden = true

        self.registrationViewController = self.storyboard?.instantiateViewController(withIdentifier: "registrationViewController") as? RegistrationViewController
        self.addChildViewController(self.registrationViewController!)
        self.view.addSubview((self.registrationViewController?.view)!)
        self.registrationViewController?.view.isHidden = true
    }
    
    /// viewWillAppear
    ///
    /// - Parameter animated: <#animated description#>
    override func viewWillAppear(_ animated: Bool) {
        print("DetailViewController#viewWillAppear")
    }

    /// セル選択時(delegate)
    ///
    /// - Parameter wine: 選択されたワイン
    func selectedCell(wine: Wine) {
        self.wine = nil
        if(self.manageMode){
            self.wine = wine
            self.registrationViewController?.selectedCell(wine: wine)
        } else {
            if wine.display {
                self.wine = wine
                self.referenceViewController?.selectedCell(wine: wine)
            }
        }
        self.changeScreen()
    }

    /// ワインの追加(delegate)
    ///
    func addWine() {
        self.registrationViewController?.addWine()

        // 画面が出ていない場合(ワインを選択していない状態)もあるため、画面の切り替えを実施する。
        self.referenceViewController?.view.isHidden = true
        self.registrationViewController?.view.isHidden = false
    }
    
    /// 管理モード設定(delegate)
    ///
    func setManageMode() {
        self.manageMode = true
        self.navigationItem.setRightBarButtonItems([self.selectButton], animated: true)

        if let wine = self.wine {
            self.selectedCell(wine: wine)
        }
        self.changeScreen()
    }
    
    /// 参照モード設定(delegate)
    ///
    func setReferenceMode() {
        self.manageMode = false
        self.navigationItem.setRightBarButtonItems(nil, animated: true)

        if let wine = self.wine {
            self.selectedCell(wine: wine)
        }
        self.changeScreen()
    }

    /// ワイン削除通知(delegate)
    ///
    func delete(wine: Wine) {
        if self.wine === wine {
            self.wine = nil
        }
        self.changeScreen()
    }
    
    /// 画面の切り替え
    ///
    func changeScreen() {
        if self.wine != nil {
            self.referenceViewController?.view.isHidden = self.manageMode
            self.registrationViewController?.view.isHidden = !self.manageMode
        } else {
            self.referenceViewController?.view.isHidden = true
            self.registrationViewController?.view.isHidden = true
        }
    }
    
    /// didReceiveMemoryWarning
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// テーブルビューのリロード
    ///
    func reloadWineTableView() {
        let masterNavController = self.splitViewController?.viewControllers.first as! UINavigationController
        let masterViewController = masterNavController.topViewController as! MasterViewController
        masterViewController.reloadWineTableView()
    }
    
    /// ワインリストの取得
    ///
    /// - Returns: ワインリスト
    func getWineList() -> WineList {
        let masterNavController = self.splitViewController?.viewControllers.first as! UINavigationController
        let masterViewController = masterNavController.topViewController as! MasterViewController
        let wineList = masterViewController.getWineList()
        return wineList
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
