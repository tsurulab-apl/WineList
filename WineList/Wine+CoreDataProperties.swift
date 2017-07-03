//
//  Wine+CoreDataProperties.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/05/30.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
import CoreData


extension Wine {

//    @nonobjc public class func fetchRequest() -> NSFetchRequest<Wine> {
//        return NSFetchRequest<Wine>(entityName: "Wine")
//    }

    @NSManaged public var category: Int16
    @NSManaged public var color: String?
    @NSManaged public var display: Bool
    //NSDataをDataに変更
    @NSManaged public var image: Data?
    //NSDateをDateに変更
    @NSManaged public var insertDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var alias: String?
    @NSManaged public var note: String?
    @NSManaged public var price: Int32
    //NSDateをDateに変更
    @NSManaged public var updateDate: Date?
    @NSManaged public var vintage: Int16
    //@NSManaged public var next: Wine?
    //@NSManaged public var previous: Wine?

}
