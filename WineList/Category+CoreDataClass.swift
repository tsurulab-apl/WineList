//
//  Category+CoreDataClass.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/06/20.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

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
