//
//  Wine+CoreDataProperties.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/07/05.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
import CoreData


extension Wine {

//    @nonobjc public class func fetchRequest() -> NSFetchRequest<Wine> {
//        return NSFetchRequest<Wine>(entityName: "Wine")
//    }

    @NSManaged public var alias: String?
    @NSManaged public var color: String?
    @NSManaged public var display: Bool
    //NSDataをDataに変更
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var price: Int32
    //NSDateをDateに変更
    @NSManaged public var insertDate: Date?
    @NSManaged public var updateDate: Date?
    @NSManaged public var vintage: Int16
//    @NSManaged public var next: Wine?
//    @NSManaged public var previous: Wine?
    @NSManaged public var category: Category?

    ///
    /// カテゴリーの変更
    ///
    func changeCategory(_ category:Category){
        self.oldCategory = self.category
        self.category = category
    }
    ///
    /// カテゴリーの変更判定
    ///
    func isChangeCategory() -> Bool {
        var isChange:Bool = true
        if self.oldCategory === self.category {
            isChange = false
        }
        return isChange
    }
}
