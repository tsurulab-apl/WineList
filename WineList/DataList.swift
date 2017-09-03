//
//  DataList.swift
//  DataList
//
//  Created by 鶴澤幸治 on 2017/06/20.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
import CoreData

//public protocol LinkedData {
//    
//    var next:LinkedData? { get set }
//    var previous:LinkedData? { get set }
//    //func fetchRequest() -> NSFetchRequest<NSManagedObject>
//}
//protocol EntityWithName {
//    static func entityName() -> String
//}

/// CoreDataで管理する順序リンク付きデータ
///
public class LinkedData: NSManagedObject {
//    class func entityName() -> String {
//        fatalError("have to override")
//    }

    class var entityName: String {
        get{
            fatalError("have to override")
        }
    }

//    var _entityName = "LinkedData"
//    var entityName: String {
//        get {
//            return self._entityName
//        }
//    }
    @NSManaged public var next: LinkedData?
    @NSManaged public var previous: LinkedData?

    override public class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        //let entityName = NSStringFromClass(type(of: self))
        //let entityName = self.entityName
        print("##### entityName=\(self.entityName)")
        return NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
    }
}

/// データリスト変更時の通知先設定用Delegate
///
protocol DataListDelegate : class {
    func changeDataList(type: LinkedData.Type)
}

/// データリスト
///
public class DataList<T: LinkedData> {
    /// 通知先
    private var delegate:Array<DataListDelegate> = []

    /// カテゴリーの先頭
    var first:T?

    /// カテゴリーの最後
    var last:T? {
        var data:T? = self.first
        while true {
            if let next = data?.next as? T {
                data = next
            } else {
                break
            }
        }
        return data
    }
    
    /// CoreDataのコンテキスト
    var managedObjectContext:NSManagedObjectContext

//    init(entityName:String, managedObjectContext:NSManagedObjectContext) {
//        self._entityName = entityName
//        self.managedObjectContext = managedObjectContext
//    }

    /// イニシャライザ
    ///
    /// - Parameter managedObjectContext: <#managedObjectContext description#>
    init(managedObjectContext:NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    /// データの取得
    ///
    func getData() {
        let data:T? = self.getFirst()
        self.first = data
    }
    
    /// 最初のデータの取得
    ///
    /// - Returns: 最初のデータ
    func getFirst() -> T? {
        var firstData:T? = nil
        let fetchRequest = T.fetchRequest()
        let predicates = [
            //NSPredicate(format: "category = %d", category.rawValue),
            NSPredicate(format: "previous == nil")
        ]
        // 複数条件をand連結可能なコードにしておく。
        let compoundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = compoundedPredicate
        do {
            let fetchData = try self.managedObjectContext.fetch(fetchRequest)
            for data in fetchData {
                firstData = data as? T
                break
            }
        } catch {
            print("Fetching Failed.")
        }
        return firstData
    }
    
    /// 件数取得
    ///
    /// - Returns: 件数
    func count() -> Int {
        var count:Int = 0
        if var data = self.first {
            while true {
                if self.isTarget(data) {
                    count += 1
                }
                if let next = data.next {
                    data = next as! T
                } else {
                    break
                }
            }
        }
        return count
    }
    
    /// 存在判定
    ///
    /// - Returns: true:存在 false:不在
    func isExists() -> Bool {
        let isExists = (self.first != nil)
        return isExists
    }
    
    /// 対象判定
    /// このメソッドを上書きし非表示データなど対象か対象外かの判定を行う。
    ///
    /// - Parameter data: データ
    /// - Returns: true:対象 false:対象外
    func isTarget(_ data:T) -> Bool {
        return true
    }
    
    /// データ取得
    ///
    /// - Parameter row: 行番号
    /// - Returns: データ
    func get(_ row: Int) -> T {
        var index:Int = -1
        var data:T = self.first!
        while true {
            if self.isTarget(data) {
                index += 1
            }
            if ( index == row ){
                break
            }
            if let next = data.next {
                data = next as! T
            } else {
                break
            }
        }
        return data
    }

    /// インデックス取得
    ///
    /// - Parameter data: データ
    /// - Returns: インデックス番号
    func index(data: T) -> Int {
        var index:Int = -1
        var listData:T = self.first!
        while true {
            if self.isTarget(listData) {
                index += 1
            }
            if ( data === listData ){
                break
            }
            if let next = listData.next {
                listData = next as! T
            } else {
                break
            }
        }
        return index
    }

    /// データ取得(Nilを含む)
    ///
    /// - Parameter row: 行番号
    /// - Returns: データ
    func getWithNil(row: Int) -> T? {
        var index:Int = 0
        var data:T? = self.first
        while data != nil {
            if ( index == row ){
                break
            }
            data = data?.next as? T
            index += 1
        }
        return data
    }
    
    /// 新しいデータの作成
    ///
    /// - Returns: 新しいデータ
    func new() -> T {
        let data = T(context: managedObjectContext)
        return data
    }
    
    /// データの削除
    ///
    /// - Parameter row: 行番号
    func delete(_ row: Int){
        let data = self.get(row)
        
        self.leave(data: data)
        
        self.managedObjectContext.delete(data)
        self.save()
    }
    
    /// 並べ替え
    ///
    /// - Parameters:
    ///   - data: データ
    ///   - toRow: 移動先の行番号
    func moveRow(data:T, toRow:Int){
        // 元の位置の調整
        self.leave(data: data)
        // 新しい位置の調整
        self.arrive(data: data, toRow: toRow)
        // 保存
        self.save()
    }
    
    /// 元の位置の調整
    ///
    /// - Parameter data: データ
    func leave(data:T){
        if let next = data.next {
            if let previous = data.previous {
                // 前後とも存在する場合は、前後を連結
                previous.next = next
            } else {
                // 後のみ存在する場合は、後ろを先頭に設定
                next.previous = nil
                self.setFirst(data: next as! T)
            }
        } else {
            if let previous = data.previous {
                // 前のみ存在する場合は、前のnextをクリア
                previous.next = nil
            } else {
                // 前後が空の場合は、先頭をクリア
                self.clearFirst()
            }
        }
    }
    
    /// 新しい位置の調整
    ///
    /// - Parameters:
    ///   - data: データ
    ///   - toRow: 移動先の行番号
    func arrive(data:T, toRow:Int){
        // 新しい位置のデータを検索
        if let position:T = self.getWithNil(row:toRow) {
            data.previous = position.previous
            data.next = position
            if data.previous == nil {
                // 先頭に設定
                self.setFirst(data: data)
            }
        } else {
            // データがない場合
            self.insert(data:data)
        }
    }

    /// データの保存
    ///
    func save(){
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Save Failed.")
        }
        // 通知先に通知
        self.notice()
    }
    
    /// データの保存
    ///
    /// - Parameter data: データ
    func save(data:T){
        if (data.isInserted) {
            self.insert(data: data)
        } else if (data.isUpdated) {
            self.update(data: data)
        }
        self.save()
    }
    
    /// データの追加
    ///
    /// - Parameter data: データ
    func insert(data:T){
        data.previous = nil
        data.next = nil
        if let last = self.last {
            last.next = data
        } else {
            // 自身を先頭に設定
            self.setFirst(data: data)
        }
    }
    
    /// データの更新
    ///
    /// - Parameter data: データ
    func update(data:T){
        // 何もしない
    }
    
    /// 先頭に設定
    ///
    /// - Parameter data: データ
    func setFirst(data:T){
        self.first = data
    }

    /// 先頭をクリア
    ///
    func clearFirst(){
        self.first = nil
    }
    
    /// 変更通知先の登録
    ///
    /// - Parameter delegate: 通知先
    func set(delegate: DataListDelegate){
        self.delegate.append(delegate)
    }
    
    /// 変更の通知
    ///
    func notice() {
        for delegate in self.delegate {
            delegate.changeDataList(type: T.self)
        }
    }

}

/// イテレーター
///
public struct DataListIterator<T: LinkedData>: IteratorProtocol {
    
    /// The current node in the iteration
    private var current: T?
    
    /// イニシャライザ
    ///
    /// - Parameter first: 最初のデータ
    public init(_ first: T?) {
        self.current = first
    }

    /// 次データの取得
    ///
    /// - Returns: 次データ
    public mutating func next() -> T? {
        let node = self.current
        current = self.current?.next as? T
        
        return node
    }
}

/// イテレーターの作成
///
extension DataList: Sequence {
    /// イテレーター
    public typealias Iterator = DataListIterator<T>
    
    /// イテレーターの作成
    ///
    /// - Returns: イテレーター
    public func makeIterator() -> DataList.Iterator {
        let dataListIterator = DataListIterator<T>(self.first)
        return dataListIterator
    }
}
