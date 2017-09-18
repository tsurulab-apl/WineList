//
//  Category.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/05/03.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import Foundation

/// イテレート可能なEmun型
///
public protocol EnumEnumerable {
    associatedtype Case = Self
}

/// イテレート可能なEmun型(拡張)
///
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

/// カテゴリー(利用していない。)
///
public enum CategoryEnum: Int16, CustomStringConvertible,EnumEnumerable {
    case White = 0
    case Red = 1
    case Rose = 2
    case Sparkling = 3

    /// raw値によるイニシャライザ
    init?(raw: Int) {
        self.init(rawValue: Int16(raw))
    }

    /// description
    ///
    public var description: String {
        switch self {
        case .White: return "White"
        case .Red   : return "Red"
        case .Rose  : return "Rose"
        case .Sparkling : return "Sparkling"
        }
    }
}

/// 資料タイプ
///
public enum MaterialType: Int16, CustomStringConvertible,EnumEnumerable {
    case vineyard = 100
    case image = 200
    case other = 9999

    /// raw値によるイニシャライザ
    ///
    init?(raw: Int16) {
        self.init(rawValue: raw)
    }

    /// index値によるイニシャライザ
    ///
    init?(index: Int) {
        switch index {
        case 0: self = .vineyard
        case 1: self = .image
        case 2: self = .other
        default: return nil
        }
    }

    /// description
    ///
    public var description: String {
        switch self {
        case .vineyard: return "Vineyard"
        case .image   : return "Image"
        case .other : return "Other"
        }
    }

    /// index
    ///
    public var index: Int {
        switch self {
        case .vineyard: return 0
        case .image   : return 1
        case .other : return 2
        }
    }
}
