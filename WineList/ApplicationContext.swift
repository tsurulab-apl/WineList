//
//  ApplicationContext.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/07/29.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit
import CoreData

///
/// アプリケーションコンテキスト
/// アプリケーション全体のデータ共有領域
///
public class ApplicationContext {
    
    /// シングルトンインスタンス
    static let instance = ApplicationContext()

    ///
    /// ワインリスト
    ///
    var wineList:WineList
    
    ///
    /// イニシャライザ(シングルトン)
    ///
    private init() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        self.wineList = WineList(managedObjectContext: viewContext)
    }
}
