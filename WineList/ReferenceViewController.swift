//
//  self.categorySegmentedControl.selectedSegmentIndex = 0 ReferenceViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/05/04.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

/// ワイン参照画面
///
class ReferenceViewController: UIViewController,UIScrollViewDelegate {
    /// 設定クラス
    private let settings = Settings.instance

    /// 選択中のワイン
    var wine: Wine? = nil

    /// 資料ボタン画像(Disabled)
    let materialButtonDisabledImage = UIImage(named: "grape_r128g128b128_32")

    /// 資料ボタン画像(Enabled)
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

    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mainScrollView.delegate = self
        //self.title = "ワイン参照"
    }

    /// didReceiveMemoryWarning
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// マスターテーブルで選択されたワインの表示
    ///
    /// - Parameter wine: ワイン
    func selectedCell(wine: Wine) {
        //self.title = "ワインの表示"
        
        self.wine = wine
        self.nameLabel.text = wine.name
        self.aliasLabel.text = wine.alias
        self.wineryLabel.text = wine.winery
        self.vintageLabel.text = String(wine.vintage)

        // 説明
        self.noteTextView.text = wine.note
        let size = self.noteTextView.sizeThatFits(CGSize(width: self.noteTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        let height = size.height
        self.noteTextView.frame.size.height = height

        if wine.priceAsk {
            self.priceLabel.text = self.settings.priceAsk
        } else {
            self.priceLabel.text = NumberUtil.japanesePrice(price: Int(wine.price))
        }

        // カテゴリー
        self.categoryLabel.text = wine.category?.name

        // ワイン画像
        if let image = wine.image {
            self.wineImageView.image = UIImage(data: image)
        }
        else{
            self.wineImageView.image = self.settings.defaultImage
        }

        // 資料ボタン
        self.materialButton.setImage(self.materialButtonDisabledImage, for: UIControlState())
        self.materialButton.isEnabled = false
        if let materials = wine.materials {
            if materials.count > 0 {
                self.materialButton.setImage(self.materialButtonEnabledImage, for: UIControlState())
                self.materialButton.isEnabled = true
            }
        }
    }

    /// スクロールビューのZoom対象を戻す。
    ///
    /// - Parameter scrollView: スクロールビュー
    /// - Returns: ズーム対象ビュー
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
     // return a view that will be scaled. if delegate returns nil, nothing happens
        return self.mainStackView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */

    /// セグエによる遷移時
    ///
    /// - Parameters:
    ///   - segue: セグエ
    ///   - sender: <#sender description#>
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
