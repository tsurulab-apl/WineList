//
//  Utils.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/06/17.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
///
/// ユーティリティー
///
public class NumberUtil {
    ///
    /// カンマ区切り
    ///
    static func separateComma(num:Int) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        let str = formatter.string(for: num)
        return str!
    }
    ///
    /// 日本円表記
    ///
    static func japanesePrice(price:Int) -> String {
        let str = "¥" + NumberUtil.separateComma(num: price)
        return str
    }
}
