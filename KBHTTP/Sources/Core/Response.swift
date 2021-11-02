//
//  Response.swift
//  KBHTTP
//
//  Created by DancewithPeng on 2021/10/26.
//

import Foundation

/// 响应
public final class Response {
    
    /// 状态码
    public var statusCode: Int
    
    /// 对应的URLRequest
    public var urlRequest: URLRequest
    
    /// 对应的HTTPURLResponse
    public var urlResponse: HTTPURLResponse
    
    /// 对应的响应数据
    public var data: Data?
    
    /// 对应解析完成的值
    public var value: Any?
    
    /// 初始化方法
    /// - Parameters:
    ///   - urlResponse: 对应的HTTPURLResponse
    ///   - urlRequest: 对应的URLRequest
    public init(urlResponse: HTTPURLResponse, urlRequest: URLRequest, data: Data?) {
        self.statusCode  = urlResponse.statusCode
        self.urlResponse = urlResponse
        self.urlRequest  = urlRequest
        self.data        = data
    }
}
