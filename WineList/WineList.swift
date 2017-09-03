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
    private var manageMode:Bool = false
    private var category:Category

    /// イニシャライザ
    ///
    init(managedObjectContext:NSManagedObjectContext,category:Category) {
        self.category = category
        super.init(managedObjectContext: managedObjectContext)
    }

    /// 最初のワインの取得
    ///
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
    func setManageMode(){
        self.manageMode = true
    }

    /// 参照モードへの変更
    ///
    func setReferenceMode(){
        self.manageMode = false
    }

    /// 管理モード判定
    ///
    func isMangeMode() -> Bool{
        return self.manageMode
    }
    
    /// 参照モード判定
    ///
    func isReferenceMode() -> Bool{
        return !self.manageMode
    }
    
    /// 対象判定
    ///
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
    //var categoryList:DataList<Category>

    /// 資料リスト
    var materialList:DataList<Material>
    
    //var firstWine:Dictionary<CategoryEnum, Wine> = [:]
    
    /// ワインデータリストのディクショナリー
    var wineDataList:Dictionary<Category, WineDataList> = [:]
    //var firstWine:Dictionary<Category, Wine> = [:]
    //var wineDictionary:Dictionary<CategoryEnum, Array<Wine>> = [:]
    
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
    func setManageMode(){
        self.manageMode = true
        for dict in self.wineDataList {
            let dataList = dict.value as WineDataList
            dataList.setManageMode()
        }
    }

    ///
    /// 参照モードへの変更
    ///
    func setReferenceMode(){
        self.manageMode = false
        for dict in self.wineDataList {
            let dataList = dict.value as WineDataList
            dataList.setReferenceMode()
        }
    }

    ///
    /// ワインの並び順の初期化
    /// 読み込んだ順序でリンクリスト化する。
    ///
/**********
    func initWineOrder(){
        self.getAllData()
        for elem in CategoryEnum.enumerate() {
            let category = elem.element
            let wineArray = self.wineDictionary[category]
            self.initWineOrderFromArray(wineArray!)
        }
        // CoreDataを保存
        self.save()
    }
***********/
    ///
    /// カテゴリーごとの配列の順に順序を付与する。
    ///
/**********
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
************/
    ///
    /// 最初のワインの初期化
    /// TODO:削除
    ///
/**********
    func initFirstWine(){
        self.firstWine = [:]
        //        for elem in CategoryEnum.enumerate() {
        //            let category = elem.element
        //            self.firstWine[category] = nil
        //        }
    }
**********/
    ///
    /// ワインディクショナリーの初期化
    ///
/************
    func initWineDictionary(){
        self.wineDictionary = [:]
        for elem in CategoryEnum.enumerate() {
            let category = elem.element
            let wineArray:Array<Wine> = []
            self.wineDictionary[category] = wineArray
        }
    }
**********/
    ///
    /// ワインディクショナリーへのワインの追加
    ///
/********
    func appendWineDictionary(wine: Wine){
        let category = CategoryEnum.init(raw: Int(wine.category))
        var wineArray = self.wineDictionary[category!]
        wineArray?.append(wine)
        self.wineDictionary.updateValue(wineArray!, forKey: category!)
    }
*********/

    ///
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
/*********
    func getData() {
        for elem in CategoryEnum.enumerate() {
            let category = elem.element
            let firstWine = self.getFirstWine(category: category)
            if let firstWine = firstWine {
                self.firstWine[category] = firstWine
            }
        }
    }
**********/
    ///
    /// 最初のワインの取得
    ///
/******
    func getFirstWine(category:Category)->Wine?{
        var first:Wine? = nil
        if let wines = category.wines {
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
**********/
/*******
    func getFirstWine(category:CategoryEnum)->Wine?{
        var firstWine:Wine? = nil
        let fetchRequest = Wine.fetchRequest()
        let predicates = [
            NSPredicate(format: "category = %d", category.rawValue),
            NSPredicate(format: "previous == nil")
        ]
        let compoundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = compoundedPredicate
        do {
            let fetchData = try self.managedObjectContext.fetch(fetchRequest)
            for wine in fetchData {
                firstWine = wine as? Wine
                break
            }
        } catch {
            print("Fetching Failed.")
        }
        return firstWine
    }
**********/
    ///
    /// データ取得
    ///
/************
    func getAllData() {
        self.initWineDictionary()
        
        // CoreDataからデータをfetchして格納
        let fetchRequest = Wine.fetchRequest()
        do {
            let fetchData = try self.managedObjectContext.fetch(fetchRequest)
            for wine in fetchData {
                self.appendWineDictionary(wine: wine as! Wine)
            }
        } catch {
            print("Fetching Failed.")
        }
    }
**************/

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
/*********
    func count(_ category:CategoryEnum) -> Int{
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
                    wine = next as! Wine
                } else {
                    break
                }
            }
        }
        return count
    }
**************/

    ///
    /// 管理モード判定
    ///
    func isMangeMode() -> Bool {
        return self.manageMode
    }

    ///
    /// 参照モード判定
    ///
    func isReferenceMode() -> Bool {
        return !self.manageMode
    }

    ///
    /// TODO:削除
    ///
/*************
    func countDictionary(_ category:CategoryEnum) -> Int{
        let wineArray = self.wineDictionary[category]
        let count = wineArray?.count
        return count!
    }
**************/

    ///
    /// ワイン取得
    ///
    func getWine(_ category:Category, _ row: Int) -> Wine {
        let dataList = self.wineDataList[category]
        let wine = dataList?.get(row)
        return wine!
    }

/******
    func getWine(_ category:CategoryEnum, _ row: Int) -> Wine{
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
                wine = next as? Wine
            } else {
                break
            }
        }
        return wine!
    }
*********/

    ///
    /// ワインの削除
    ///
    func delete(_ category:Category, _ row: Int){
        let wine = self.getWine(category,row)
        
        self.leave(wine: wine)
        
        self.managedObjectContext.delete(wine)
        self.save()
    }
/*******
    func delete(_ category:CategoryEnum, _ row: Int){
        let wine = self.getWine(category,row)
        
        self.leave(wine: wine)
        
        self.managedObjectContext.delete(wine)
        self.save()
    }
*********/

    ///
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
    /// TODO:削除
    ///
/*********
    func getWineDictionary(_ category:CategoryEnum, _ row: Int) -> Wine{
        let wineArray = self.wineDictionary[category]
        let wine = wineArray?[row]
        return wine!
    }
************/

    ///
    /// 新しいワインの作成
    ///
    func newWine()->Wine{
        let wine = Wine(context: managedObjectContext)
        return wine
    }

    ///
    /// カテゴリー内の最後のワインを取得
    ///
/*******
    func getLastWine(category:CategoryEnum) -> Wine?{
        var wine = self.firstWine[category]
        while true {
            if let next = wine?.next {
                wine = next as? Wine
            } else {
                break
            }
        }
        return wine
    }
**********/

    ///
    /// カテゴリー内のワインの存在判定
    ///
    func isExists(category:Category) -> Bool {
        var isExists:Bool = false
        if let dataList = self.wineDataList[category] {
            isExists = dataList.isExists()
        }
        return isExists
    }
/********
    func isExists(category:CategoryEnum) -> Bool{
        let wine = self.firstWine[category]
        let isExists = (wine != nil)
        return isExists
    }
*********/

    ///
    /// ワインの保存
    ///
    func save(wine:Wine){
        if (wine.isInserted) {
            self.insert(wine: wine)
        } else if (wine.isUpdated) {
            self.update(wine: wine)
        }
        self.save()
    }

    ///
    /// ワインの追加
    ///
    func insert(wine:Wine){
        let category = wine.category
        if let dataList = self.wineDataList[category!] {
            dataList.insert(data: wine)
        }
    }
/***********
    func insert(wine:Wine){
        let category = CategoryEnum.init(raw: Int(wine.category))
        wine.previous = nil
        wine.next = nil
        if let last = self.getLastWine(category: category!) {
            last.next = wine
        } else {
            // 自身をカテゴリーの先頭に設定
            self.setFirst(wine: wine)
        }
    }
**************/

    ///
    /// ワインの更新
    ///
    func update(wine:Wine){
        let isChange = self.isChangeCategory(wine: wine)
        if isChange {
            // 元の位置の調整
            self.leave(wine: wine)
            // 自身をカテゴリーの最後に追加
            self.insert(wine: wine)
        }
    }

    ///
    /// カテゴリーの先頭に設定
    ///
    func setFirst(wine:Wine){
        let category = wine.category
        if let dataList = self.wineDataList[category!] {
            dataList.setFirst(data: wine)
        }
    }
/*******
    func setFirst(wine:Wine){
        let category = CategoryEnum.init(raw: Int(wine.category))
        self.firstWine[category!] = wine
    }
*********/

    ///
    /// カテゴリーの先頭をクリア
    ///
    func clearFirst(wine:Wine){
        for (_, dataList) in self.wineDataList {
            // ===で参照が同じかを確認
            if wine === dataList.first {
                dataList.clearFirst()
                break
            }
        }
    }
/****
    func clearFirst(wine:Wine){
        for elem in CategoryEnum.enumerate() {
            let category = elem.element
            let firstWine = self.firstWine[category]
            if let firstWine = firstWine {
                // ===で参照が同じかを確認
                if firstWine === wine {
                    self.firstWine[category] = nil
                    break
                }
            }
        }
    }
***********/

    ///
    /// カテゴリーの変更判定
    ///
    func isChangeCategory(wine:Wine) -> Bool {
        let isChange = wine.isChangeCategory()
        return isChange
/******
        var isChange:Bool = false
        if let next = wine.next {
            isChange = ((next as! Wine).category != wine.category)
        } else {
            if let previous = wine.previous {
                isChange = ((previous as! Wine).category != wine.category)
            } else {
                // next/previousともにnilの場合
                // カテゴリー内に別のワインが存在すれば、変更判定をtrueとする。
                // 別のワインがない場合でもカテゴリーの変更はあり得るが、その場合はnext,previousの設定
                // は不要なため、ここでは判定しない。
                //let category = CategoryEnum.init(raw: Int(wine.category))
                let category = wine.category!
                let isExists = self.isExists(category: category)
                if isExists {
                    isChange = true
                }
            }
        }
        return isChange
*********/
    }
/*******
    func isChangeCategory(wine:Wine)->Bool {
        var isChange:Bool = false
        if let next = wine.next {
            isChange = ((next as! Wine).category != wine.category)
        } else {
            if let previous = wine.previous {
                isChange = ((previous as! Wine).category != wine.category)
            } else {
                // next/previousともにnilの場合
                // カテゴリー内に別のワインが存在すれば、変更判定をtrueとする。
                // 別のワインがない場合でもカテゴリーの変更はあり得るが、その場合はnext,previousの設定
                // は不要なため、ここでは判定しない。
                let category = CategoryEnum.init(raw: Int(wine.category))
                let isExists = self.isExists(category: category!)
                if isExists {
                    isChange = true
                }
            }
        }
        return isChange
    }
***********/

    ///
    /// 並べ替え
    ///
    func moveRow(wine:Wine, toCategory:Category, toRow:Int){
        // 元の位置の調整
        self.leave(wine: wine)
        // 新しい位置の調整
        self.arrive(wine: wine, toCategory: toCategory, toRow: toRow)
        // 保存
        self.save()
    }
/*******
    func moveRow(wine:Wine, toCategory:CategoryEnum, toRow:Int){
        // 元の位置の調整
        self.leave(wine: wine)
        // 新しい位置の調整
        self.arrive(wine: wine, toCategory: toCategory, toRow: toRow)
        // 保存
        self.save()
    }
*********/

    ///
    /// 元の位置の調整
    ///
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

    ///
    /// 新しい位置の調整
    ///
    func arrive(wine:Wine, toCategory:Category, toRow:Int){
        // 新しいカテゴリーを設定
        wine.category = toCategory
        let dataList = self.wineDataList[toCategory]
        dataList?.arrive(data: wine, toRow: toRow)
    }
/***********
    func arrive(wine:Wine, toCategory:CategoryEnum, toRow:Int){
        // 新しいカテゴリーを設定
        wine.category = toCategory.rawValue
        
        // 新しい位置のワインを検索
        if let position:Wine = self.getWineWithNil(category:toCategory, row:toRow) {
            wine.previous = position.previous
            wine.next = position
            if wine.previous == nil {
                // カテゴリーの先頭の設定
                self.setFirst(wine: wine)
            }
        } else {
            // 当該カテゴリーにワインがない場合
            self.insert(wine:wine)
        }
    }
****************/
    ///
    /// ワイン取得(Nilを含む)
    ///
/*********
    func getWineWithNil(category:CategoryEnum, row: Int) -> Wine?{
        var index:Int = 0
        var wine:Wine? = self.firstWine[category]
        while wine != nil {
            if ( index == row ){
                break
            }
            wine = wine?.next as? Wine
            index += 1
        }
        return wine
    }
*************/

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
///
///
///
/********************************************************
public class WineList2 {
    private var manageMode:Bool = false

    var firstWine:Dictionary<CategoryEnum, Wine> = [:]
    var wineDictionary:Dictionary<CategoryEnum, Array<Wine>> = [:]
    var managedObjectContext:NSManagedObjectContext
    ///
    /// イニシャライザ
    ///
    init(managedObjectContext:NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
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
        self.getAllData()
        for elem in CategoryEnum.enumerate() {
            let category = elem.element
            let wineArray = self.wineDictionary[category]
            self.initWineOrderFromArray(wineArray!)
        }
        // CoreDataを保存
        self.save()
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
    /// TODO:削除
    ///
    func initFirstWine(){
        self.firstWine = [:]
//        for elem in CategoryEnum.enumerate() {
//            let category = elem.element
//            self.firstWine[category] = nil
//        }
    }
    ///
    /// ワインディクショナリーの初期化
    ///
    func initWineDictionary(){
        self.wineDictionary = [:]
        for elem in CategoryEnum.enumerate() {
            let category = elem.element
            let wineArray:Array<Wine> = []
            self.wineDictionary[category] = wineArray
        }
    }
    ///
    /// ワインディクショナリーへのワインの追加
    ///
    func appendWineDictionary(wine: Wine){
        let category = CategoryEnum.init(raw: Int(wine.category))
        var wineArray = self.wineDictionary[category!]
        wineArray?.append(wine)
        self.wineDictionary.updateValue(wineArray!, forKey: category!)
    }
    ///
    /// ワインの取得
    ///
    func getData() {
        for elem in CategoryEnum.enumerate() {
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
    func getFirstWine(category:CategoryEnum)->Wine?{
        var firstWine:Wine? = nil
        let fetchRequest = Wine.fetchRequest()
        let predicates = [
            NSPredicate(format: "category = %d", category.rawValue),
            NSPredicate(format: "previous == nil")
        ]
        let compoundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = compoundedPredicate
        do {
            let fetchData = try self.managedObjectContext.fetch(fetchRequest)
            for wine in fetchData {
                firstWine = wine as? Wine
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
        
        // CoreDataからデータをfetchして格納
        let fetchRequest = Wine.fetchRequest()
        do {
            let fetchData = try self.managedObjectContext.fetch(fetchRequest)
            for wine in fetchData {
                self.appendWineDictionary(wine: wine as! Wine)
            }
        } catch {
            print("Fetching Failed.")
        }
    }
    ///
    /// 件数取得
    ///
    func count(_ category:CategoryEnum) -> Int{
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
                    wine = next as! Wine
                } else {
                    break
                }
            }
        }
        return count
    }
    ///
    /// 管理モード判定
    ///
    func isMangeMode() -> Bool{
        return self.manageMode
    }
    ///
    /// 参照モード判定
    ///
    func isReferenceMode() -> Bool{
        return !self.manageMode
    }
    ///
    /// TODO:削除
    ///
    func countDictionary(_ category:CategoryEnum) -> Int{
        let wineArray = self.wineDictionary[category]
        let count = wineArray?.count
        return count!
    }
    ///
    /// ワイン取得
    ///
    func getWine(_ category:CategoryEnum, _ row: Int) -> Wine{
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
                wine = next as? Wine
            } else {
                break
            }
        }
        return wine!
    }
    ///
    /// ワインの削除
    ///
    func delete(_ category:CategoryEnum, _ row: Int){
        let wine = self.getWine(category,row)
        
        self.leave(wine: wine)

        self.managedObjectContext.delete(wine)
        self.save()
    }
    ///
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
    /// TODO:削除
    ///
    func getWineDictionary(_ category:CategoryEnum, _ row: Int) -> Wine{
        let wineArray = self.wineDictionary[category]
        let wine = wineArray?[row]
        return wine!
    }
    ///
    /// 新しいワインの作成
    ///
    func newWine()->Wine{
        let wine = Wine(context: managedObjectContext)
        return wine
    }
    ///
    /// カテゴリー内の最後のワインを取得
    ///
    func getLastWine(category:CategoryEnum) -> Wine?{
        var wine = self.firstWine[category]
        while true {
            if let next = wine?.next {
                wine = next as? Wine
            } else {
                break
            }
        }
        return wine
    }
    ///
    /// カテゴリー内のワインの存在判定
    ///
    func isExists(category:CategoryEnum) -> Bool{
        let wine = self.firstWine[category]
        let isExists = (wine != nil)
        return isExists
    }
    ///
    /// ワインの保存
    ///
    func save(wine:Wine){
        if (wine.isInserted) {
            self.insert(wine: wine)
        } else if (wine.isUpdated) {
            self.update(wine: wine)
        }
        self.save()
    }
    ///
    /// ワインの追加
    ///
    func insert(wine:Wine){
        let category = CategoryEnum.init(raw: Int(wine.category))
        wine.previous = nil
        wine.next = nil
        if let last = self.getLastWine(category: category!) {
            last.next = wine
        } else {
            // 自身をカテゴリーの先頭に設定
            self.setFirst(wine: wine)
        }
    }
    ///
    /// ワインの更新
    ///
    func update(wine:Wine){
        let isChange = self.isChangeCategory(wine: wine)
        if isChange {
            // 元の位置の調整
            self.leave(wine: wine)
            // 自身をカテゴリーの最後に追加
            self.insert(wine: wine)
        }
    }
    ///
    /// カテゴリーの先頭に設定
    ///
    func setFirst(wine:Wine){
        let category = CategoryEnum.init(raw: Int(wine.category))
        self.firstWine[category!] = wine
    }
    ///
    /// カテゴリーの先頭をクリア
    ///
    func clearFirst(wine:Wine){
        for elem in CategoryEnum.enumerate() {
            let category = elem.element
            let firstWine = self.firstWine[category]
            if let firstWine = firstWine {
                // ===で参照が同じかを確認
                if firstWine === wine {
                    self.firstWine[category] = nil
                    break
                }
            }
        }
    }
    ///
    /// カテゴリーの変更判定
    ///
    func isChangeCategory(wine:Wine)->Bool {
        var isChange:Bool = false
        if let next = wine.next {
            isChange = ((next as! Wine).category != wine.category)
        } else {
            if let previous = wine.previous {
                isChange = ((previous as! Wine).category != wine.category)
            } else {
                // next/previousともにnilの場合
                // カテゴリー内に別のワインが存在すれば、変更判定をtrueとする。
                // 別のワインがない場合でもカテゴリーの変更はあり得るが、その場合はnext,previousの設定
                // は不要なため、ここでは判定しない。
                let category = CategoryEnum.init(raw: Int(wine.category))
                let isExists = self.isExists(category: category!)
                if isExists {
                    isChange = true
                }
            }
        }
        return isChange
    }
    ///
    /// 並べ替え
    ///
    func moveRow(wine:Wine, toCategory:CategoryEnum, toRow:Int){
        // 元の位置の調整
        self.leave(wine: wine)
        // 新しい位置の調整
        self.arrive(wine: wine, toCategory: toCategory, toRow: toRow)
        // 保存
        self.save()
    }
    ///
    /// 元の位置の調整
    ///
    func leave(wine:Wine){
        if let next = wine.next {
            if let previous = wine.previous {
                // 前後とも存在する場合は、前後を連結
                previous.next = next
            } else {
                // 後のみ存在する場合は、後ろを先頭に設定
                next.previous = nil
                setFirst(wine: next as! Wine)
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
    ///
    /// 新しい位置の調整
    ///
    func arrive(wine:Wine, toCategory:CategoryEnum, toRow:Int){
        // 新しいカテゴリーを設定
        wine.category = toCategory.rawValue

        // 新しい位置のワインを検索
        if let position:Wine = self.getWineWithNil(category:toCategory, row:toRow) {
            wine.previous = position.previous
            wine.next = position
            if wine.previous == nil {
                // カテゴリーの先頭の設定
                self.setFirst(wine: wine)
            }
        } else {
            // 当該カテゴリーにワインがない場合
            self.insert(wine:wine)
        }
    }
    ///
    /// ワイン取得(Nilを含む)
    ///
    func getWineWithNil(category:CategoryEnum, row: Int) -> Wine?{
        var index:Int = 0
        var wine:Wine? = self.firstWine[category]
        while wine != nil {
            if ( index == row ){
                break
            }
            wine = wine?.next as? Wine
            index += 1
        }
        return wine
    }
}
********************************************************************/
