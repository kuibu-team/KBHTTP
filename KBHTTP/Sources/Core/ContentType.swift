//
//  ContentType.swift
//  KBHTTP
//
//  Created by DancewithPeng on 2021/11/1.
//

import Foundation

/// 内容类型
public struct ContentType: CustomStringConvertible, ExpressibleByStringLiteral, Equatable {
    
    /// 主类型
    public var type: String
    /// 子类型
    public var subType: String
    
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        let types = value.components(separatedBy: "/")
        self.type = types.first ?? "*"
        if types.count > 1, let subType = types.last {
            self.subType = subType
        } else {
            self.subType = "*"
        }
    }
    
    public var description: String {
        guard subType.count > 0 else {
            return type
        }
        
        guard type.count > 0 else {
            return subType
        }
        
        return "\(type)/\(subType)"
    }
}

// MARK: - 常用内容类型
public extension ContentType {
    static let json       : ContentType = "application/json"
    static let urlencoded : ContentType = "application/x-www-form-urlencoded"
    static let png        : ContentType = "image/png"
    static let jpeg       : ContentType = "image/jpeg"
    static let gif        : ContentType = "image/gif"
    static let formData   : ContentType = "multipart/form-data"
}
