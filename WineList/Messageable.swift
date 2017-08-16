//
//  Messageable.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/08/16.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
import UIKit

/// メッセージ表示機能のプロトコル
///
protocol Messageable {
}

/// メッセージ表示機能のプロトコル拡張
///
extension Messageable where Self: UIViewController {

    /// 保存メッセージの表示
    ///
    func showSaveMessage() {
        self.showMessage(title: "保存しました。", message: "")
    }
    
    /// リセットメッセージの表示
    ///
    func showResetMessage() {
        self.showMessage(title: "リセットしました。", message: "")
    }
    
    /// Invalidメッセージの表示
    ///
    /// - Parameter message: メッセージ
    func showInvalidMessage(message:String) {
        self.showMessage(title: "確認", message: message)
    }
    
    /// メッセージ表示
    ///
    /// - Parameters:
    ///   - title: タイトル文字列
    ///   - message: メッセージ文字列
    func showMessage(title:String, message:String) {
        
        // アラート作成
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // アラート表示
        self.present(alert, animated: true, completion: {
            // アラートを自動で閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })
    }
}
