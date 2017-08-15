//
//  self.categorySegmentedControl.selectedSegmentIndex = 0 ReferenceViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/05/04.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

class ReferenceViewController: UIViewController,UIScrollViewDelegate {
    // ワイン
    var wine: Wine? = nil

    // デフォルトワイン画像
    let defaultImageName = "two-types-of-wine-1761613_640.jpg"

    // 資料ボタン画像
    //let materialButtonDisabledImage = UIImage(named: "grape_r211g211b211_32")
    let materialButtonDisabledImage = UIImage(named: "grape_r128g128b128_32")
    let materialButtonEnabledImage = UIImage(named: "grape_r66g134b244_32")
    
    // コントロール
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var wineImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var wineryLabel: UILabel!
    @IBOutlet weak var vintageLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!

    @IBOutlet weak var materialButton: UIButton!

    ///
    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ReferenceViewController.viewDidLoad")

        self.mainScrollView.delegate = self
        self.title = "ワイン参照"
        // センタリング
//        let x = self.view.center.x
//        self.wineImageView.center.x = x
//        self.nameLabel.center.x = x
//        self.vintageLabel.center.x = x
//        self.noteLabel.center.x = x
//        self.priceLabel.center.x = x
        
        // Do any additional setup after loading the view.
    }

    ///
    ///
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
/*******
    override func viewDidAppear(_ animated: Bool) {
        print("### viewDidAppear")
    }
    override func viewWillAppear(_ animated: Bool) {
        print("### viewWillAppear")
    }
    override func viewWillLayoutSubviews() {
        print("### viewWillLayoutSubviews")
    }
    override func viewDidLayoutSubviews() {
        print("### viewDidLayoutSubviews")
    }
***************/
    
    ///
    /// マスターテーブルで選択されたワインの表示
    ///
    func selectedCell(wine: Wine) {
        self.title = "ワインの表示"
        
        self.wine = wine
        self.nameLabel.text = wine.name
        self.aliasLabel.text = wine.alias
        self.wineryLabel.text = wine.winery
        self.vintageLabel.text = String(wine.vintage)

        // 説明
        self.noteTextView.text = wine.note
        //let height = StringUtil.height(text: wine.note!)
        //print(height)
        let noteSize = self.noteTextView.contentSize
        print(noteSize)
        
        //self.noteTextView.sizeToFit()
        let size = self.noteTextView.sizeThatFits(CGSize(width: self.noteTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        let height = size.height
        self.noteTextView.frame.size.height = height
        print(self.noteTextView.contentSize)
        //self.mainScrollView.contentSize.height = self.mainScrollView.contentSize.height + height - 100
//        let heightConstraint = self.noteTextView.heightAnchor.constraint(equalToConstant: height)
//        heightConstraint.isActive = true
        //self.noteTextView.heightAnchor.constraint(equalToConstant: height).isActive = true

        //self.noteTextView.frame.size.height = height
        
        //self.noteTextView.sizeToFit()
        //self.priceLabel.text = "¥" + self.separateComma(num: Int(wine.price))
        self.priceLabel.text = NumberUtil.japanesePrice(price: Int(wine.price))
        self.categoryLabel.text = wine.category?.name
//        let category = CategoryEnum.init(raw: Int(wine.category))
//        self.categoryLabel.text = category?.description
        // ワイン画像
        if let image = wine.image {
            self.wineImageView.image = UIImage(data: image)
        }
        else{
            //self.wineImageView.image = nil
            //self.wineImageView.image = UIImage(named: self.defaultImageName)
            self.wineImageView.image = Settings.instance.defaultImage
        }
        // 資料ボタン
        //self.materialButton.isHidden = true
        self.materialButton.setImage(self.materialButtonDisabledImage, for: UIControlState())
        self.materialButton.isEnabled = false
        if let materials = wine.materials {
            if materials.count > 0 {
                //self.materialButton.isHidden = false
                self.materialButton.setImage(self.materialButtonEnabledImage, for: UIControlState())
                self.materialButton.isEnabled = true
            }
        }
        //
//        self.view.layoutIfNeeded()
    }

    ///
    /// カンマ区切り
    ///
/*****
    func separateComma(num:Int) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        let str = formatter.string(for: num)
        return str!
    }
************/
    ///
    /// スクロールビューのZoom対象を戻す。
    ///
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
     // return a view that will be scaled. if delegate returns nil, nothing happens
        return self.mainStackView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    ///
    /// セグエによる遷移時
    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        // 資料参照ポップアップ
        if segue.identifier == "PopupMaterialReference" {
            let popupMaterialReferenceViewController = segue.destination as! PopupMaterialReferenceViewController
            popupMaterialReferenceViewController.wine = self.wine
        }
    }

}
