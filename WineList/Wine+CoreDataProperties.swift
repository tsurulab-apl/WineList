//
//  Wine+CoreDataProperties.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/07/22.
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
    @NSManaged public var winery: String?
    @NSManaged public var price: Int32
    @NSManaged public var priceAsk: Bool
    //NSDateをDateに変更
    @NSManaged public var insertDate: Date?
    @NSManaged public var updateDate: Date?
    @NSManaged public var vintage: Int16
    @NSManaged public var category: Category?
//    @NSManaged public var next: Wine?
//    @NSManaged public var previous: Wine?
    @NSManaged public var materials: NSSet?

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

// MARK: Generated accessors for materials
extension Wine {

    @objc(addMaterialsObject:)
    @NSManaged public func addToMaterials(_ value: Material)

    @objc(removeMaterialsObject:)
    @NSManaged public func removeFromMaterials(_ value: Material)

    @objc(addMaterials:)
    @NSManaged public func addToMaterials(_ values: NSSet)

    @objc(removeMaterials:)
    @NSManaged public func removeFromMaterials(_ values: NSSet)

}
