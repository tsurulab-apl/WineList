//
//  Category.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/05/03.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation

public protocol EnumEnumerable {
    associatedtype Case = Self
}

public extension EnumEnumerable where Case: Hashable {
    private static var iterator: AnyIterator<Case> {
        var n = 0
        return AnyIterator {
            defer { n += 1 }
            
            let next = withUnsafePointer(to: &n) {
                UnsafeRawPointer($0).assumingMemoryBound(to: Case.self).pointee
            }
            return next.hashValue == n ? next : nil
        }
    }
    
    public static func enumerate() -> EnumeratedSequence<AnySequence<Case>> {
        return AnySequence(self.iterator).enumerated()
    }
    
    public static var cases: [Case] {
        return Array(self.iterator)
    }
    
    public static var count: Int {
        return self.cases.count
    }
}
/**
 * カテゴリー
 */
public enum Category: Int16, CustomStringConvertible,EnumEnumerable {
    case White = 0
    case Red = 1
    case Rose = 2
    case Sparkling = 3
    
    //var description: String { return rawValue }
    public var description: String {
        switch self {
        case .White: return "White"
        case .Red   : return "Red"
        case .Rose  : return "Rose"
        case .Sparkling : return "Sparkling"
        }
    }
}
