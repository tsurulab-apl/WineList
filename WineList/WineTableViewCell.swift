//
//  WineTableViewCell.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/08/09.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

class WineTableViewCell: UITableViewCell {

    // コントロール
    @IBOutlet weak var wineImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    ///
    /// awakeFromNib
    ///
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    ///
    /// setSelected
    ///
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
