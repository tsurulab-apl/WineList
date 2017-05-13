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
    @IBOutlet weak var vintageLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ReferenceViewController.viewDidLoad")
        
        self.title = "ワイン参照"

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
        self.vintageLabel.text = String(wine.vintage)
        self.noteLabel.text = wine.note
        self.priceLabel.text = String(wine.price)
        if let image = wine.image {
            self.wineImageView.image = UIImage(data: image)
        }
        else{
            self.wineImageView.image = nil
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
