//
//  DictionaryConvertible.swift
//  KBHTTP
//
//  Created by DancewithPeng on 2021/10/29.
//

import Foundation

/// 可转化字典协议
public protocol DictionaryConvertible {
    
    /// 转化为字典
    func asDictionary() throws -> [String: Any]?
}
