//
//  Settings.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/06/14.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
import UIKit

///
/// 設定変更時の通知先設定用Delegate
///
protocol SettingsDelegate: class {
    func changeSettings()
}

///
/// 設定
///
public class Settings {
    // 通知先
    private var delegate:Array<SettingsDelegate> = []
    
    // デフォルト値
    private static let DEFAULT_PASSWORD = "0000"
    private static let DEFAULT_LONG_PRESS_DURATION:Double = 1.0
    //private static let DEFAULT_IMAGE_NAME = "two-types-of-wine-1761613_640.jpg"
    private static let DEFAULT_IMAGE_NAME = "now_printing"

    // UserDefaultsのキー
    private static let KEY_PASSWORD = "password"
    private static let KEY_LONG_PRESS_DURATION = "longPressDuration"
    private static let KEY_DEFAULT_IMAGE = "defaultImage"

    // UserDefaults
    private var userDefaults = UserDefaults.standard

    // デフォルト画像のデフォルト
    var defaultDefaultImage:UIImage
    
    /// シングルトンインスタンス
    static let instance = Settings()

    ///
    /// 管理モード用パスワード
    ///
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

    ///
    /// 管理モードへの遷移用長押し秒数
    ///
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

    ///
    /// デフォルト画像
    ///
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

    ///
    /// デフォルト画像のクリア
    ///
    func clearDefaultImage() {
        userDefaults.removeObject(forKey: Settings.KEY_DEFAULT_IMAGE)
    }
    
    ///
    /// イニシャライザ(シングルトン)
    ///
    private init() {
        self.defaultDefaultImage = UIImage(named: Settings.DEFAULT_IMAGE_NAME)!
    }

    ///
    /// 変更通知先の登録
    ///
    func set(delegate: SettingsDelegate){
        self.delegate.append(delegate)
    }

    ///
    /// 変更の通知
    ///
    func notice() {
        for delegate in self.delegate {
            delegate.changeSettings()
        }
    }
}
