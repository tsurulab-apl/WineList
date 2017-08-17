//
//  Utils.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/06/17.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
import UIKit

/// 数値ユーティリティー
///
public class NumberUtil {

    /// カンマ区切り
    ///
    /// - Parameter num: 数値
    /// - Returns: カンマ区切り文字列
    static func separateComma(num:Int) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        let str = formatter.string(for: num)
        return str!
    }

    /// 日本円表記
    ///
    /// - Parameter price: 価格
    /// - Returns: 日本円表記文字列
    static func japanesePrice(price:Int) -> String {
        let str = "¥" + NumberUtil.separateComma(num: price)
        return str
    }
}

/// 文字列ユーティリティー
///
public class StringUtil {

    /// UILabelやUITextViewで必要な高さを計算する。
    ///
    /// - Parameter text: 高さを計算する文字列
    /// - Returns: UILabelやUITextViewで必要な高さ
    static func height(text: String) -> CGFloat {
        
        let horizonMergin:CGFloat = 32
        let verticalMergin:CGFloat = 32
        
        let attr = NSMutableAttributedString(string: text)
        
        let paragrahStyle = NSMutableParagraphStyle()
        paragrahStyle.lineHeightMultiple = 1.3
        paragrahStyle.lineSpacing = 4
        
        attr.addAttribute(NSParagraphStyleAttributeName, value: paragrahStyle, range: NSMakeRange(0, attr.length))
        
        
        let maxSize = CGSize(width: UIScreen.main.bounds.width - horizonMergin, height: CGFloat.greatestFiniteMagnitude)
        let options = unsafeBitCast(
            NSStringDrawingOptions.usesLineFragmentOrigin.rawValue |
                NSStringDrawingOptions.usesFontLeading.rawValue,
            to: NSStringDrawingOptions.self)
        
        let font = UIFont.systemFont(ofSize: 14.0)
        attr.addAttribute("font", value: font, range: NSRange(location: 0, length: attr.length))
        //attr.addFontAttribute(font, range: NSRange(location: 0, length: attr.length))
        
        let frame = attr.boundingRect(with: maxSize,
                                              options: options,
                                              context: nil)
        let height = ceil(frame.size.height) + verticalMergin
        
        return height
    }
}
