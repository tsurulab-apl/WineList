//
//  Category+CoreDataProperties.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/07/05.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
import CoreData


extension Category {

//    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
//        return NSFetchRequest<Category>(entityName: "Category")
//    }

    @NSManaged public var insertDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var updateDate: Date?
    //@NSManaged public var next: Category?
    //@NSManaged public var previous: Category?
    @NSManaged public var wines: NSSet?

}

// MARK: Generated accessors for wines
extension Category {

    @objc(addWinesObject:)
    @NSManaged public func addToWines(_ value: Wine)

    @objc(removeWinesObject:)
    @NSManaged public func removeFromWines(_ value: Wine)

    @objc(addWines:)
    @NSManaged public func addToWines(_ values: NSSet)

    @objc(removeWines:)
    @NSManaged public func removeFromWines(_ values: NSSet)

}
