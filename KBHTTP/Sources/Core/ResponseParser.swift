//
//  ResponseParser.swift
//  KBHTTP
//
//  Created by DancewithPeng on 2021/10/26.
//

import Foundation

/// 响应解析器
public protocol ResponseParser {
        
    /// 解析响应
    func parse(response: Response) throws -> Any?
}
