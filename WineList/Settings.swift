//
//  Settings.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/06/14.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation

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
    private static let DEFAULT_LONG_TAP_DURATION:Float = 1.0
    private static let DEFAULT_LONG_PRESS_DURATION:Double = 1.0

    // UserDefaultsのキー
    private static let KEY_PASSWORD = "password"
    private static let KEY_LONG_TAP_DURATION = "longTapDuration"
    private static let KEY_LONG_PRESS_DURATION = "longPressDuration"

    // UserDefaults
    private var userDefaults = UserDefaults.standard

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
    /// イニシャライザ(シングルトン)
    ///
    private init() {
    }
    
    ///
    /// 管理モード用パスワードの設定
    ///
    func set(password:String?) {
        // nilは保存しないが、空文字はそのまま保存する。
        if let password = password {
            userDefaults.set(password, forKey: Settings.KEY_PASSWORD)
        }
    }
    ///
    /// 管理モード用パスワードの取得
    ///
    func getPassword() -> String {
        if let password = userDefaults.string(forKey: Settings.KEY_PASSWORD) {
            return password
        }
        return Settings.DEFAULT_PASSWORD
    }
    ///
    /// 管理モードへの遷移用長押し秒数の設定
    ///
    func set(longTapDuration:Float?) {
        if let longTapDuration = longTapDuration {
            userDefaults.set(longTapDuration, forKey: Settings.KEY_LONG_TAP_DURATION)
        }
    }
    ///
    /// 管理モードへの遷移用長押し秒数
    ///
    func getLongTapDuration() -> Float {
        let longTapDuration = userDefaults.float(forKey: Settings.KEY_LONG_TAP_DURATION)
        if longTapDuration > 0.0 {
            return longTapDuration
        }
        return Settings.DEFAULT_LONG_TAP_DURATION
    }
   
}
