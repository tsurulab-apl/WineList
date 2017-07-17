//
//  Wine+CoreDataClass.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/05/01.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
import CoreData

@objc(Wine)
public class Wine: LinkedData {
    var oldCategory:Category?
    override class var entityName: String {
        get {
            return "Wine"
        }
    }
}
