//
//  Category.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/06/20.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//
/******************************************
import Foundation
import CoreData

public class CategoryList {
    // カテゴリーの先頭
    var first:Category?

    // カテゴリーの最後
    var last:Category? {
        var category = self.first
        while true {
            if let next = category?.next {
                category = next
            } else {
                break
            }
        }
        return category
    }
    //
    var managedObjectContext:NSManagedObjectContext
    ///
    /// イニシャライザ
    ///
    init(managedObjectContext:NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    ///
    /// カテゴリーの取得
    ///
    func getData() {
        let category:Category? = self.getFirst()
        self.first = category
    }
    ///
    /// 最初のカテゴリーの取得
    ///
    func getFirst() -> Category? {
        var firstCategory:Category? = nil
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        let predicates = [
            //NSPredicate(format: "category = %d", category.rawValue),
            NSPredicate(format: "previous == nil")
        ]
        // 複数条件をand連結可能なコードにしておく。
        let compoundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = compoundedPredicate
        do {
            let fetchData = try self.managedObjectContext.fetch(fetchRequest)
            for category in fetchData {
                firstCategory = category
                break
            }
        } catch {
            print("Fetching Failed.")
        }
        return firstCategory
    }
    ///
    /// 件数取得
    ///
    func count() -> Int {
        var count:Int = 0
        if var category = self.first {
            while true {
                count += 1
                if let next = category.next {
                    category = next
                } else {
                    break
                }
            }
        }
        return count
    }
    ///
    /// カテゴリー取得
    ///
    func get(_ row: Int) -> Category {
        var index:Int = -1
        var category:Category = self.first!
        while true {
            index += 1
            if ( index == row ){
                break
            }
            if let next = category.next {
                category = next
            } else {
                break
            }
        }
        return category
    }

    ///
    /// カテゴリー取得(Nilを含む)
    ///
    func getWithNil(row: Int) -> Category? {
        var index:Int = 0
        var category:Category? = self.first
        while category != nil {
            if ( index == row ){
                break
            }
            category = category?.next
            index += 1
        }
        return category
    }
    
    ///
    /// 新しいカテゴリーの作成
    ///
    func new() -> Category {
        let category = Category(context: managedObjectContext)
        return category
    }
    
    ///
    /// カテゴリーの削除
    ///
    func delete(_ row: Int){
        let category = self.get(row)
        
        self.leave(category: category)
        
        self.managedObjectContext.delete(category)
        self.save()
    }
    ///
    /// 並べ替え
    ///
    func moveRow(category:Category, toRow:Int){
        // 元の位置の調整
        self.leave(category: category)
        // 新しい位置の調整
        self.arrive(category: category, toRow: toRow)
        // 保存
        self.save()
    }
    ///
    /// 元の位置の調整
    ///
    func leave(category:Category){
        if let next = category.next {
            if let previous = category.previous {
                // 前後とも存在する場合は、前後を連結
                previous.next = next
            } else {
                // 後のみ存在する場合は、後ろを先頭に設定
                next.previous = nil
                self.setFirst(category: next)
            }
        } else {
            if let previous = category.previous {
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
    func arrive(category:Category, toRow:Int){
        // 新しい位置のカテゴリーを検索
        if let position:Category = self.getWithNil(row:toRow) {
            category.previous = position.previous
            category.next = position
            if category.previous == nil {
                // 先頭に設定
                self.setFirst(category: category)
            }
        } else {
            // カテゴリーがない場合
            self.insert(category:category)
        }
    }

    ///
    /// カテゴリーの保存
    ///
    func save(){
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Save Failed.")
        }
    }
    ///
    /// カテゴリーの保存
    ///
    func save(category:Category){
        if (category.isInserted) {
            self.insert(category: category)
        } else if (category.isUpdated) {
            self.update(category: category)
        }
        self.save()
    }
    ///
    /// カテゴリーの追加
    ///
    func insert(category:Category){
        category.previous = nil
        category.next = nil
        if let last = self.last {
            last.next = category
        } else {
            // 自身を先頭に設定
            self.setFirst(category: category)
        }
    }
    ///
    /// カテゴリーの更新
    ///
    func update(category:Category){
        // 何もしない
    }
    ///
    /// 先頭に設定
    ///
    func setFirst(category:Category){
        self.first = category
    }
    ///
    /// 先頭をクリア
    ///
    func clearFirst(){
        self.first = nil
    }

}
*************************/
/*****
 import Foundation
 import CoreData
 
 @objc(Category)
 public class Category: LinkedData {
 override class var entityName: String {
 get {
 return "Category"
 }
 }
 
 //    override class func entityName() -> String {
 //        return "Category"
 //    }
 }
 import Foundation
 import CoreData
 
 
 extension Category {
 
 //    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
 //        return NSFetchRequest<Category>(entityName: "Category")
 //    }
 //    override convenience init(context:NSManagedObjectContext) {
 //        self.init(context: context)
 //        self._entityName = "Category"
 //    }
 
 @NSManaged public var insertDate: Date?
 @NSManaged public var name: String?
 @NSManaged public var updateDate: Date?
 //@NSManaged public var next: Category?
 //@NSManaged public var previous: Category?
 
 }

 *****/
