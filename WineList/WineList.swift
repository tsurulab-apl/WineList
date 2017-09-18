//
//  WineList.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/05/18.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
import CoreData

/// ワインのデータリスト
/// あるカテゴリーのワインリストを保持する。
/// ワインリストクラス内でDictionaryに格納して利用する。
///
public class WineDataList:DataList<Wine> {

    /// 管理モード
    private var manageMode:Bool = false

    /// カテゴリー
    private var category:Category

    /// イニシャライザ
    ///
    /// - Parameters:
    ///   - managedObjectContext: CoreDataの管理コンテキスト
    ///   - category: カテゴリー
    init(managedObjectContext:NSManagedObjectContext,category:Category) {
        self.category = category
        super.init(managedObjectContext: managedObjectContext)
    }

    /// 最初のワインの取得
    ///
    /// - Returns: 最初のワイン
    override func getFirst() -> Wine? {
        var first:Wine? = nil
        if let wines = self.category.wines {
            for wineAny in wines {
                let wine = wineAny as! Wine
                if wine.previous == nil {
                    first = wine
                    break
                }
            }
        }
        return first
    }
    
    /// 管理モードへの変更
    ///
    func setManageMode() {
        self.manageMode = true
    }

    /// 参照モードへの変更
    ///
    func setReferenceMode() {
        self.manageMode = false
    }

    /// 管理モード判定
    ///
    /// - Returns: true:管理モード false:参照モード
    func isMangeMode() -> Bool{
        return self.manageMode
    }
    
    /// 参照モード判定
    ///
    /// - Returns: true:参照モード false:管理モード
    func isReferenceMode() -> Bool{
        return !self.manageMode
    }
    
    /// 対象判定
    /// 参照モード時に非表示設定されたワインは対象外とする。
    ///
    /// - Parameter data: ワイン
    /// - Returns: true:対象 false:対象外
    override func isTarget(_ data:Wine) -> Bool {
        var isTarget:Bool = true
        if self.isReferenceMode() {
            if !data.display {
                isTarget = false
            }
        }
        return isTarget
    }
}


/// カテゴリーリスト
///
public class CategoryList:DataList<Category> {
    
    /// サンプルデータリスト
    private let sampleDataList = ["White", "Red", "Rose", "Sparkling"]
    
    /// サンプルデータ作成
    ///
    func sampleData() {
        for sample in self.sampleDataList {
            let category = self.new()
            category.name = sample
            let now = Date()
            category.insertDate = now
            category.updateDate = now
            self.save(data: category)
        }
    }
}


/// ワインリスト
///
public class WineList: DataListDelegate {
    /// 管理モード
    private var manageMode:Bool = false

    /// カテゴリーリスト
    var categoryList:CategoryList

    /// 資料リスト
    var materialList:DataList<Material>
    
    /// ワインデータリストのディクショナリー
    var wineDataList:Dictionary<Category, WineDataList> = [:]
    
    /// CoreDataコンテキスト
    var managedObjectContext:NSManagedObjectContext

    /// イニシャライザ
    ///
    /// - Parameter managedObjectContext: CoreDataコンテキスト
    init(managedObjectContext:NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        //self.categoryList = DataList<Category>(managedObjectContext:managedObjectContext)
        self.categoryList = CategoryList(managedObjectContext: managedObjectContext)
        self.materialList = DataList<Material>(managedObjectContext:managedObjectContext)

        // カテゴリー変更時の通知を受信する設定
        self.categoryList.set(delegate: self)

        // データの取得
        self.getData()
        //self.categoryList.getData()
    }

    /// 管理モードへの変更
    ///
    func setManageMode() {
        self.manageMode = true
        for dict in self.wineDataList {
            let dataList = dict.value as WineDataList
            dataList.setManageMode()
        }
    }

    /// 参照モードへの変更
    ///
    func setReferenceMode() {
        self.manageMode = false
        for dict in self.wineDataList {
            let dataList = dict.value as WineDataList
            dataList.setReferenceMode()
        }
    }

    /// データ読み込み
    /// ワイン、カテゴリー、資料のデータをCoreDataから読み込む
    /// イニシャライザからのみ呼び出す。
    ///
    private func getData() {
        self.wineDataList.removeAll()

        // カテゴリー
        self.categoryList.getData()
        // カテゴリー毎にワインを読み込む
        for category in categoryList {
            let dataList = WineDataList(managedObjectContext: self.managedObjectContext, category: category)
            dataList.getData()
            self.wineDataList[category] = dataList
        }
        // 資料
        self.materialList.getData()
    }

    ///
    /// 件数取得
    ///
    func count(_ category:Category) -> Int{
        var count:Int = 0
        if let dataList = self.wineDataList[category] {
            count = dataList.count()
        }
        return count
    }

    /// 管理モード判定
    ///
    /// - Returns: true:管理モード false:参照モード
    func isMangeMode() -> Bool {
        return self.manageMode
    }

    /// 参照モード判定
    ///
    /// - Returns: true:参照モード false:管理モード
    func isReferenceMode() -> Bool {
        return !self.manageMode
    }

    /// ワイン取得
    ///
    /// - Parameters:
    ///   - category: カテゴリー
    ///   - row: 行番号
    /// - Returns: ワイン
    func getWine(_ category:Category, _ row: Int) -> Wine {
        let dataList = self.wineDataList[category]
        let wine = dataList?.get(row)
        return wine!
    }

    /// ワインの削除
    ///
    /// - Parameters:
    ///   - category: カテゴリー
    ///   - row: 行番号
    func delete(_ category:Category, _ row: Int){
        let wine = self.getWine(category,row)
        
        self.leave(wine: wine)
        
        self.managedObjectContext.delete(wine)
        self.save()
    }

    /// ワインリストの保存
    ///
    func save(){
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Save Failed.")
        }
    }

    ///
    /// 新しいワインの作成
    ///
    /// - Returns: ワイン
    func newWine() -> Wine{
        let wine = Wine(context: managedObjectContext)
        return wine
    }

    /// カテゴリー内のワインの存在判定
    ///
    /// - Parameter category: カテゴリー
    /// - Returns: true:存在 false:不在
    func isExists(category:Category) -> Bool {
        var isExists:Bool = false
        if let dataList = self.wineDataList[category] {
            isExists = dataList.isExists()
        }
        return isExists
    }

    /// ワインの保存
    ///
    /// - Parameter wine: ワイン
    func save(wine:Wine){
        if (wine.isInserted) {
            self.insert(wine: wine)
        } else if (wine.isUpdated) {
            self.update(wine: wine)
        }
        self.save()
    }

    /// ワインの追加
    ///
    func insert(wine:Wine){
        let category = wine.category
        if let dataList = self.wineDataList[category!] {
            dataList.insert(data: wine)
        }
    }

    /// ワインの更新
    ///
    /// - Parameter wine: ワイン
    func update(wine:Wine){
        let isChange = self.isChangeCategory(wine: wine)
        if isChange {
            // 元の位置の調整
            self.leave(wine: wine)
            // 自身をカテゴリーの最後に追加
            self.insert(wine: wine)
        }
    }

    /// カテゴリーの先頭に設定
    ///
    /// - Parameter wine: ワイン
    func setFirst(wine:Wine){
        let category = wine.category
        if let dataList = self.wineDataList[category!] {
            dataList.setFirst(data: wine)
        }
    }

    /// カテゴリーの先頭をクリア
    ///
    /// - Parameter wine: ワイン
    func clearFirst(wine:Wine){
        for (_, dataList) in self.wineDataList {
            // ===で参照が同じかを確認
            if wine === dataList.first {
                dataList.clearFirst()
                break
            }
        }
    }

    /// カテゴリーの変更判定
    ///
    /// - Parameter wine: ワイン
    /// - Returns: true:カテゴリー変更 false:変更なし
    func isChangeCategory(wine:Wine) -> Bool {
        let isChange = wine.isChangeCategory()
        return isChange
    }

    /// 並べ替え
    ///
    /// - Parameters:
    ///   - wine: ワイン
    ///   - toCategory: 移動先カテゴリー
    ///   - toRow: 移動先行番号
    func moveRow(wine:Wine, toCategory:Category, toRow:Int){
        // 元の位置の調整
        self.leave(wine: wine)
        // 新しい位置の調整
        self.arrive(wine: wine, toCategory: toCategory, toRow: toRow)
        // 保存
        self.save()
    }

    /// 元の位置の調整
    ///
    /// - Parameter wine: ワイン
    func leave(wine:Wine){
        if let next = wine.next {
            if let previous = wine.previous {
                // 前後とも存在する場合は、前後を連結
                previous.next = next
            } else {
                // 後のみ存在する場合は、後ろを先頭に設定
                next.previous = nil
                self.setFirst(wine: next as! Wine)
            }
        } else {
            if let previous = wine.previous {
                // 前のみ存在する場合は、前のnextをクリア
                previous.next = nil
            } else {
                // 前後が空の場合は、カテゴリーの先頭をクリア
                self.clearFirst(wine: wine)
            }
        }
    }

    /// 新しい位置の調整
    ///
    /// - Parameters:
    ///   - wine: ワイン
    ///   - toCategory: 移動先カテゴリー
    ///   - toRow: 移動先行番号
    func arrive(wine:Wine, toCategory:Category, toRow:Int){
        // 新しいカテゴリーを設定
        wine.category = toCategory
        let dataList = self.wineDataList[toCategory]
        dataList?.arrive(data: wine, toRow: toRow)
    }

    /// カテゴリー変更時処理
    ///
    /// - Parameter type: リンクデータの型(カテゴリー)
    func changeDataList(type: LinkedData.Type) {
        if type is Category.Type {
            self.getData()
        }
    }
    
    /// サンプルデータ作成
    ///
    func sampleData() {
        self.categoryList.sampleData()
    }
}
