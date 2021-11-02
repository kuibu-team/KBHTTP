//
//  RequestSender.swift
//  KBHTTP
//
//  Created by DancewithPeng on 2021/10/26.
//

import Foundation

/// 请求发送器
public protocol RequestSender {
    
    /// 发送请求，如果失败，抛出异常
    /// - Parameters:
    ///   - request: 请求
    ///   - completionHandler: 完成的处理
    func send(request: KBHTTP.Request,
              completionHandler: @escaping ((Result<KBHTTP.Response, Swift.Error>) -> Void)) throws
    
    /// 取消请求
    /// - Parameters:
    ///   - request: 要取消的请求
    func cancel(request: KBHTTP.Request) throws
}
