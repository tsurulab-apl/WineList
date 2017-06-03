//
//  WineList.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/05/18.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
import CoreData

public class WineList {
    private var manageMode:Bool = false

    var firstWine:Dictionary<Category, Wine> = [:]
    var wineDictionary:Dictionary<Category, Array<Wine>> = [:]
    var managedObjectContext:NSManagedObjectContext
    ///
    /// イニシャライザ
    ///
    init(managedObjectContext:NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.initWineDictionary()
        self.initFirstWine()
    }
    ///
    /// 管理モードへの変更
    ///
    func setManageMode(){
        self.manageMode = true
    }
    ///
    /// 参照モードへの変更
    ///
    func setReferenceMode(){
        self.manageMode = false
    }
    ///
    /// ワインの並び順の初期化
    /// 読み込んだ順序でリンクリスト化する。
    ///
    func initWineOrder(){
        for elem in Category.enumerate() {
            let category = elem.element
            let wineArray = self.wineDictionary[category]
            self.initWineOrderFromArray(wineArray!)
        }
        // CoreDataを保存
        do{
            try self.managedObjectContext.save()
        }catch{
            print(error)
        }
    }
    ///
    /// カテゴリーごとの配列の順に順序を付与する。
    ///
    func initWineOrderFromArray(_ wineArray:Array<Wine>) {
        var previousWine:Wine? = nil
        for wine in wineArray {
            wine.previous = previousWine
            previousWine = wine
        }
        if let lastWine = previousWine {
            lastWine.next = nil
        }
    }
    ///
    /// 最初のワインの初期化
    ///
    func initFirstWine(){
        self.firstWine = [:]
//        for elem in Category.enumerate() {
//            let category = elem.element
//            self.firstWine[category] = nil
//        }
    }
    ///
    /// ワインディクショナリーの初期化
    ///
    func initWineDictionary(){
        self.wineDictionary = [:]
        for elem in Category.enumerate() {
            let category = elem.element
            let wineArray:Array<Wine> = []
            self.wineDictionary[category] = wineArray
        }
    }
    ///
    /// ワインディクショナリーへのワインの追加
    ///
    func appendWineDictionary(wine: Wine){
        let category = Category.init(raw: Int(wine.category))
        var wineArray = self.wineDictionary[category!]
        wineArray?.append(wine)
        self.wineDictionary.updateValue(wineArray!, forKey: category!)
    }
    ///
    /// ワインの取得
    ///
    func getData() {
        for elem in Category.enumerate() {
            let category = elem.element
            let firstWine = self.getFirstWine(category: category)
            if let firstWine = firstWine {
                self.firstWine[category] = firstWine
            }
        }
    }
    ///
    /// 最初のワインの取得
    ///
    func getFirstWine(category:Category)->Wine?{
        var firstWine:Wine? = nil
        let fetchRequest: NSFetchRequest<Wine> = Wine.fetchRequest()
//        let predicates = [
//            NSPredicate(format: "category = %@", category.rawValue),
//            NSPredicate(format: "previous == nil")
//        ]
        let predicates = [
            NSPredicate(format: "category = %d", category.rawValue),
            NSPredicate(format: "previous == nil")
        ]
        let compoundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = compoundedPredicate
        do {
            let fetchData = try self.managedObjectContext.fetch(fetchRequest)
            for wine in fetchData {
                firstWine = wine
                break
            }
        } catch {
            print("Fetching Failed.")
        }
        return firstWine
    }
    ///
    /// データ取得
    ///
    func getAllData() {
        self.initWineDictionary()
        
        // CoreDataからデータをfetchしてtasksに格納
        let fetchRequest: NSFetchRequest<Wine> = Wine.fetchRequest()
        do {
            let fetchData = try self.managedObjectContext.fetch(fetchRequest)
            for wine in fetchData {
                self.appendWineDictionary(wine: wine)
            }
        } catch {
            print("Fetching Failed.")
        }
    }
    ///
    /// 件数取得
    ///
    func count(_ category:Category) -> Int{
        var count:Int = 0
        if var wine = self.firstWine[category] {
            while true {
                if(self.isReferenceMode()){
                    if(wine.display){
                        count += 1
                    }
                } else {
                    count += 1
                }
                if let next = wine.next {
                    wine = next
                } else {
                    break
                }
            }
        }
        return count
    }
    func isMangeMode() -> Bool{
        return self.manageMode
    }
    func isReferenceMode() -> Bool{
        return !self.manageMode
    }
    ///
    /// TODO:削除
    ///
    func countDictionary(_ category:Category) -> Int{
        let wineArray = self.wineDictionary[category]
        let count = wineArray?.count
        return count!
    }
    ///
    /// ワイン取得
    ///
    func getWine(_ category:Category, _ row: Int) -> Wine{
//        var count:Int = 0
//        var wine:Wine? = self.firstWine[category]!
//        while wine != nil {
//            if ( count == row ){
//                break
//            }
//            wine = wine?.next
//            count += 1
//        }
//        return wine!
        var index:Int = -1
        var wine = self.firstWine[category]
        while true {
            if(self.isReferenceMode()){
                if(wine?.display)!{
                    index += 1
                }
            } else {
                index += 1
            }
            if ( index == row ){
                break
            }
            if let next = wine?.next {
                wine = next
            } else {
                break
            }
        }
        return wine!
    }
    ///
    /// TODO:削除
    ///
    func getWineDictionary(_ category:Category, _ row: Int) -> Wine{
        let wineArray = self.wineDictionary[category]
        let wine = wineArray?[row]
        return wine!
    }
}
/********
 import Foundation
 import CoreData
 
 
 extension Wine {
 
 @nonobjc public class func fetchRequest() -> NSFetchRequest<Wine> {
 return NSFetchRequest<Wine>(entityName: "Wine")
 }
 
 @NSManaged public var category: Int16
 @NSManaged public var color: String?
 //NSDataをDataに変更
 @NSManaged public var image: Data?
 @NSManaged public var name: String?
 @NSManaged public var note: String?
 @NSManaged public var vintage: Int16
 @NSManaged public var price: Int32
 @NSManaged public var display: Bool
 //NSDateをDateに変更
 @NSManaged public var insertDate: Date?
 @NSManaged public var updateDate: Date?
 
 }

 *********/
