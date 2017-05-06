//
//  Wine+CoreDataProperties.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/05/03.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
import CoreData


extension Wine {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Wine> {
        return NSFetchRequest<Wine>(entityName: "Wine")
    }

    @NSManaged public var color: String?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var vintage: Int16
    // NSDataからData型に変更(再作成時に注意)
    @NSManaged public var image: Data?
    @NSManaged public var category: Int16

}
