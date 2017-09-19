//
//  Settings.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/06/14.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
import UIKit

/// 設定変更時の通知先設定用Delegate
///
protocol SettingsDelegate: class {
    func changeSettings()
}

/// 設定
///
public class Settings {
    /// 通知先
    private var delegate:Array<SettingsDelegate> = []
    
    // デフォルト値
    private static let DEFAULT_PASSWORD = "0000"
    private static let DEFAULT_LONG_PRESS_DURATION:Double = 1.0
    private static let DEFAULT_IMAGE_NAME = "NowPrinting"
    private static let DEFAULT_PRICE:Int = 5000
    private static let DEFAULT_PRICE_ASK = "Ask"
    private static let DEFAULT_VINTAGE_RANGE:Int = 50

    // UserDefaultsのキー
    private static let KEY_APP_FIRST_PROCESSED = "appFirstProcessed"
    private static let KEY_PASSWORD = "password"
    private static let KEY_LONG_PRESS_DURATION = "longPressDuration"
    private static let KEY_DEFAULT_IMAGE = "defaultImage"
    private static let KEY_DEFAULT_PRICE = "defaultPrice"
    private static let KEY_PRICE_ASK = "priceAsk"
    private static let KEY_VINTAGE_RANGE = "vintageRange"

    /// UserDefaults
    private var userDefaults = UserDefaults.standard

    /// デフォルト画像のデフォルト
    var defaultDefaultImage:UIImage
    
    /// シングルトンインスタンス
    static let instance = Settings()

    /// 初回処理済みフラグ
    var appFirstProcessed:Bool {
        get {
            let appFirstProcessed = userDefaults.bool(forKey: Settings.KEY_APP_FIRST_PROCESSED)
            return appFirstProcessed
        }
        set {
            userDefaults.set(newValue, forKey: Settings.KEY_APP_FIRST_PROCESSED)
        }
    }

    /// 管理モード用パスワード
    var password:String {
        get {
            if let password = userDefaults.string(forKey: Settings.KEY_PASSWORD) {
                return password
            }
            return Settings.DEFAULT_PASSWORD
        }
        set {
            userDefaults.set(newValue, forKey: Settings.KEY_PASSWORD)
        }
    }

    /// 管理モードへの遷移用長押し秒数
    var longPressDuration:Double {
        get {
            let longPressDuration = userDefaults.double(forKey: Settings.KEY_LONG_PRESS_DURATION)
            if longPressDuration > 0.0 {
                return longPressDuration
            }
            return Settings.DEFAULT_LONG_PRESS_DURATION
        }
        set {
            userDefaults.set(newValue, forKey: Settings.KEY_LONG_PRESS_DURATION)
        }
    }

    /// デフォルト画像
    var defaultImage:UIImage {
        get {
            if let data = userDefaults.data(forKey: Settings.KEY_DEFAULT_IMAGE) {
                let defaultImage = UIImage(data: data)!
                return defaultImage
            }
            return self.defaultDefaultImage
        }
        set {
            userDefaults.set(newValue.jpegData, forKey: Settings.KEY_DEFAULT_IMAGE)
        }
    }

    /// デフォルト画像のクリア
    func clearDefaultImage() {
        userDefaults.removeObject(forKey: Settings.KEY_DEFAULT_IMAGE)
    }

    /// デフォルト価格
    var defaultPrice:Int {
        get {
            let defaultPrice = userDefaults.integer(forKey: Settings.KEY_DEFAULT_PRICE)
            if defaultPrice > 0 {
                return defaultPrice
            }
            return Settings.DEFAULT_PRICE
        }
        set {
            userDefaults.set(newValue, forKey: Settings.KEY_DEFAULT_PRICE)
        }
    }

    /// デフォルト価格のクリア
    func clearDefaultPrice() {
        userDefaults.removeObject(forKey: Settings.KEY_DEFAULT_PRICE)
    }

    /// 価格Ask
    var priceAsk:String {
        get {
            if let priceAsk = userDefaults.string(forKey: Settings.KEY_PRICE_ASK) {
                return priceAsk
            }
            return Settings.DEFAULT_PRICE_ASK
        }
        set {
            userDefaults.set(newValue, forKey: Settings.KEY_PRICE_ASK)
        }
    }

    /// ヴィンテージ範囲
    var vintageRange:Int {
        get {
            let vintageRange = userDefaults.integer(forKey: Settings.KEY_VINTAGE_RANGE)
            if vintageRange > 0 {
                return vintageRange
            }
            return Settings.DEFAULT_VINTAGE_RANGE
        }
        set {
            userDefaults.set(newValue, forKey: Settings.KEY_VINTAGE_RANGE)
        }
    }

    /// ヴィンテージ範囲のクリア
    func clearVintageRange() {
        userDefaults.removeObject(forKey: Settings.KEY_VINTAGE_RANGE)
    }

    /// イニシャライザ(シングルトン)
    ///
    private init() {
        self.defaultDefaultImage = UIImage(named: Settings.DEFAULT_IMAGE_NAME)!
    }

    /// 変更通知先の登録
    ///
    func set(delegate: SettingsDelegate) {
        self.delegate.append(delegate)
    }

    /// 変更の通知
    ///
    func notice() {
        for delegate in self.delegate {
            delegate.changeSettings()
        }
    }
}
