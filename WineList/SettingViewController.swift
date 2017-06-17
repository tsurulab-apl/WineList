//
//  SettingViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/06/13.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    // 設定クラス
    private let settings = Settings.instance
    
    // ナビゲーションバーボタン
    private var saveButton:UIBarButtonItem

    // コントロール
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var longPressDurationLabel: UILabel!
    @IBOutlet weak var longPressDurationSlider: UISlider!

    ///
    /// イニシャライザ
    ///
    required init?(coder aDecoder: NSCoder) {
        // BarButton
        self.saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
        
        super.init(coder: aDecoder)
        // super.initの後にselfを設定可能
        self.saveButton.target = self
        self.saveButton.action = #selector(saveButtonAction(_:))
    }

    ///
    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "設定"

        // ナビゲーションバーボタンの作成
        self.navigationItem.setRightBarButtonItems([self.saveButton], animated: true)

        // Do any additional setup after loading the view.
    }

    ///
    /// viewWillAppear
    ///
    override func viewWillAppear(_ animated: Bool) {
        print("SettingViewController#viewWillAppear")
        self.showData()
    }

    ///
    /// didReceiveMemoryWarning
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    ///
    /// ナビゲーションバーの保存ボタン
    ///
    func saveButtonAction(_ sender: Any){
        print("saveButtonAction")
        self.savePassword()
        self.saveLongPressDuration()
    }
    ///
    /// データの表示
    ///
    func showData(){
        self.passwordTextField.text = settings.password
        let longPressDuration = self.settings.longPressDuration
        self.longPressDurationSlider.value = Float(longPressDuration)
        self.longPressDurationSliderValueChanged(self.longPressDurationSlider)
    }
    ///
    /// パスワードの保存
    ///
    func savePassword(){
        // nilは保存しないが、空文字はそのまま保存する。
        if let password = self.passwordTextField.text {
            self.settings.password = password
            //self.settings.set(password:password)
        }
    }
    ///
    /// 長押し設定の保存
    ///
    func saveLongPressDuration(){
        var longPressDuration = self.longPressDurationSlider.value
        longPressDuration = roundf(longPressDuration * 10) /  10
        self.settings.longPressDuration = Double(longPressDuration)
    }
    
    ///
    /// 長押し設定の値変更時
    ///
    @IBAction func longPressDurationSliderValueChanged(_ sender: UISlider) {
        var second = sender.value
        second = roundf(second * 10) /  10
        self.longPressDurationLabel.text = "\(second)s"
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
