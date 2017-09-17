//
//  AppDelegate.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/04/12.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit
import CoreData

/// AppDelegate
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// ウインドウ
    var window: UIWindow?

    /// アプリ起動時
    ///
    /// - Parameters:
    ///   - application: アプリケーション
    ///   - launchOptions: 起動オプション
    /// - Returns: <#return value description#>
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // 初回起動時にサンプルデータ作成
        //print("appFirstProcessed=\(Settings.instance.appFirstProcessed)")
        if !Settings.instance.appFirstProcessed {
            let wineList = ApplicationContext.instance.wineList
            wineList.sampleData()
            // 初回処理済みフラグを設定
            Settings.instance.appFirstProcessed = true
        }
/******
        //スプリットビューコントローラーを取得する。
        let splitViewController = self.window!.rootViewController as! UISplitViewController

        //常に両方表示にセット
        //splitViewController.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
        
        //マスター部のテーブルビューコントローラーを取得する。
        let masterNavController = splitViewController.viewControllers.first as! UINavigationController
        let masterViewController = masterNavController.topViewController as! MasterViewController
        
        //新しいボタンは戻るボタンの横に追加されるように設定する。
        masterViewController.navigationItem.leftItemsSupplementBackButton = true
        
        //マスター部のナビゲーションバーの左ボタンに画面モードの切り替えボタンを追加する。
        masterViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem

        //ディテール部のビューコントローラーを取得する。
        let detailNavController = splitViewController.viewControllers.last as! UINavigationController
        let detailViewController = detailNavController.topViewController as! DetailViewController
        
        //新しいボタンは戻るボタンの横に追加されるように設定する。
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        
        //ディテール部のナビゲーションバーの左ボタンに画面モードの切り替えボタンを設定する。
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        
        //マスター部のデリゲート先にディテール部のビューコントローラーを設定する。
        masterViewController.delegate = detailViewController as MasterViewControllerDelegate
************/
        return true
    }

    /// アプリを閉じる前
    ///
    /// - Parameter application: アプリケーション
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    /// アプリを閉じた時
    ///
    /// - Parameter application: アプリケーション
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    /// アプリを開く前
    ///
    /// - Parameter application: アプリケーション
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    /// アプリを開いた時
    ///
    /// - Parameter application: アプリケーション
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    /// アプリを終了する前
    ///
    /// - Parameter application: アプリケーション
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "WineList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

