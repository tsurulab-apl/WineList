//
//  Category+CoreDataProperties.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/06/20.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var insertDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var updateDate: Date?
    @NSManaged public var next: Category?
    @NSManaged public var previous: Category?

}
