//
//  self.categorySegmentedControl.selectedSegmentIndex = 0 ReferenceViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/05/04.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

class ReferenceViewController: UIViewController {
    var wine: Wine? = nil

    @IBOutlet weak var wineImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var vintageLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!

    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ReferenceViewController.viewDidLoad")
        
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

    //
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // マスターテーブルで選択されたワインの表示
    func selectedCell(wine: Wine) {
        self.title = "ワインの表示"
        
        self.wine = wine
        self.nameLabel.text = wine.name
        self.aliasLabel.text = wine.alias
        self.vintageLabel.text = String(wine.vintage)
        self.noteTextView.text = wine.note
        //self.noteTextView.sizeToFit()
        self.priceLabel.text = "¥" + self.separateComma(num: Int(wine.price))
        let category = Category.init(raw: Int(wine.category))
        self.categoryLabel.text = category?.description
        if let image = wine.image {
            self.wineImageView.image = UIImage(data: image)
        }
        else{
            self.wineImageView.image = nil
        }
    }
    // カンマ区切り
    func separateComma(num:Int) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        let str = formatter.string(for: num)
        return str!
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
