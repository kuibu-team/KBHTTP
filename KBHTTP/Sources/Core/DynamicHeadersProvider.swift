//
//  DynamicHeadersProvider.swift
//  KBHTTP
//
//  Created by DancewithPeng on 2021/10/26.
//

import Foundation

/// 动态头部提供者
public protocol DynamicHeadersProvider {
    
    /// 动态头部
    var dynamicHeaders: [String: String]? { get }
}
