//
//  MaterialSelectCollectionViewCell.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/07/29.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

/// 資料選択画面用のコレクションビューセル(イメージビュー)
///
class MaterialSelectCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dataImageView: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!

    /// 値のクリア
    /// セルの再利用時に呼び出す。
    ///
    func clear() {
        self.dataImageView.image = nil
        self.noteTextView.text = nil
        self.nameLabel.text = nil

        self.dataImageView.isHidden = false
        self.noteTextView.isHidden = false
    }
}
