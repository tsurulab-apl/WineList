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
    var wineDictionary:Dictionary<Category, Array<Wine>> = [:]
    var managedObjectContext:NSManagedObjectContext
    //
    init(managedObjectContext:NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.initWineDictionary()
    }

    // ワインディクショナリーの初期化
    func initWineDictionary(){
        self.wineDictionary = [:]
        for elem in Category.enumerate() {
            let category = elem.element
            let wineArray:Array<Wine> = []
            self.wineDictionary[category] = wineArray
        }
    }
    // ワインディクショナリーへのワインの追加
    func appendWineDictionary(wine: Wine){
        let category = Category.init(raw: Int(wine.category))
        var wineArray = self.wineDictionary[category!]
        wineArray?.append(wine)
        self.wineDictionary.updateValue(wineArray!, forKey: category!)
    }
    //
    func getData() {
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
    //
    func get(category:Category, row: Int){
        
    }
    

}
