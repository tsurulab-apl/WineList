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
///
///
///
public class DataList<T: LinkedData> {
    // カテゴリーの先頭
    var first:T?

    // カテゴリーの最後
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
    //
    var managedObjectContext:NSManagedObjectContext

    ///
    /// イニシャライザ
    ///
//    init(entityName:String, managedObjectContext:NSManagedObjectContext) {
//        self._entityName = entityName
//        self.managedObjectContext = managedObjectContext
//    }
    init(managedObjectContext:NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    ///
    /// カテゴリーの取得
    ///
    func getData() {
        let data:T? = self.getFirst()
        self.first = data
    }
    ///
    /// 最初のカテゴリーの取得
    ///
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
    ///
    /// 件数取得
    ///
    func count() -> Int {
        var count:Int = 0
        if var data = self.first {
            while true {
                count += 1
                if let next = data.next {
                    data = next as! T
                } else {
                    break
                }
            }
        }
        return count
    }
    ///
    /// データ取得
    ///
    func get(_ row: Int) -> T {
        var index:Int = -1
        var data:T = self.first!
        while true {
            index += 1
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

    ///
    /// データ取得(Nilを含む)
    ///
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
    
    ///
    /// 新しいデータの作成
    ///
    func new() -> T {
        let data = T(context: managedObjectContext)
        return data
    }
    
    ///
    /// カテゴリーの削除
    ///
    func delete(_ row: Int){
        let data = self.get(row)
        
        self.leave(data: data)
        
        self.managedObjectContext.delete(data)
        self.save()
    }
    ///
    /// 並べ替え
    ///
    func moveRow(data:T, toRow:Int){
        // 元の位置の調整
        self.leave(data: data)
        // 新しい位置の調整
        self.arrive(data: data, toRow: toRow)
        // 保存
        self.save()
    }
    ///
    /// 元の位置の調整
    ///
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
    
    ///
    /// 新しい位置の調整
    ///
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

    ///
    /// データの保存
    ///
    func save(){
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Save Failed.")
        }
    }
    ///
    /// データの保存
    ///
    func save(data:T){
        if (data.isInserted) {
            self.insert(data: data)
        } else if (data.isUpdated) {
            self.update(data: data)
        }
        self.save()
    }
    ///
    /// データの追加
    ///
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
    ///
    /// データの更新
    ///
    func update(data:T){
        // 何もしない
    }
    ///
    /// 先頭に設定
    ///
    func setFirst(data:T){
        self.first = data
    }
    ///
    /// 先頭をクリア
    ///
    func clearFirst(){
        self.first = nil
    }

}
