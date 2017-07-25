//
//  Material+CoreDataProperties.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/07/22.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
import CoreData


extension Material {

//    @nonobjc public class func fetchRequest() -> NSFetchRequest<Material> {
//        return NSFetchRequest<Material>(entityName: "Material")
//    }

    @NSManaged public var name: String?
    //NSDataをDataに変更
    @NSManaged public var data: Data?
    @NSManaged public var type: Int16
    @NSManaged public var note: String?
    //NSDateをDateに変更
    @NSManaged public var insertDate: Date?
    @NSManaged public var updateDate: Date?
//    @NSManaged public var next: Material?
//    @NSManaged public var previous: Material?
    @NSManaged public var wines: NSSet?

}

// MARK: Generated accessors for wines
extension Material {

    @objc(addWinesObject:)
    @NSManaged public func addToWines(_ value: Wine)

    @objc(removeWinesObject:)
    @NSManaged public func removeFromWines(_ value: Wine)

    @objc(addWines:)
    @NSManaged public func addToWines(_ values: NSSet)

    @objc(removeWines:)
    @NSManaged public func removeFromWines(_ values: NSSet)

}
