//
//  Material+CoreDataClass.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/07/22.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation
import CoreData

@objc(Material)
public class Material: LinkedData {
    override class var entityName: String {
        get {
            return "Material"
        }
    }
}
