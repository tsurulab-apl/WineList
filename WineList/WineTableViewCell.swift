//
//  WineTableViewCell.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/08/09.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

/// ワインのマスターテーブルのセル
///
class WineTableViewCell: UITableViewCell {

    // コントロール
    @IBOutlet weak var wineImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    /// awakeFromNib
    ///
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    /// setSelected
    ///
    /// - Parameters:
    ///   - selected: <#selected description#>
    ///   - animated: <#animated description#>
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    /// 値のクリア
    /// セルの再利用時に呼び出す。
    ///
    func clear() {
        self.wineImageView.image = nil
        self.nameLabel.text = nil
        self.priceLabel.text = nil
        self.nameLabel.textColor = nil
        self.priceLabel.textColor = nil
    }

}
