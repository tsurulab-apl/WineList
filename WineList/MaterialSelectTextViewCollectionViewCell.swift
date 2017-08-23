//
//  MaterialSelectTextViewCollectionViewCell.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/08/21.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

/// 資料選択画面用のコレクションビューセル(テキストビュー)
///
class MaterialSelectTextViewCollectionViewCell: UICollectionViewCell {
    
    // コントロール
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!

    /// 値のクリア
    /// セルの再利用時に呼び出す。
    ///
    func clear() {
        self.noteTextView.text = nil
        self.nameLabel.text = nil
    }
}
