//
//  Interface.swift
//  KBHTTP
//
//  Created by DancewithPeng on 2021/10/28.
//

import Foundation


// MARK: - RequestInterface

/// 请求接口
public protocol RequestInterface {
    
    /// 请求参数
    associatedtype RequestParameters: DictionaryConvertible
    /// 响应错误
    associatedtype ResponseError: InterfaceError
    /// 响应值
    associatedtype ResponseValue
    
    /// 请求方式
    var method: KBHTTP.Request.Method { get }
    /// 请求的URL
    var url: URL { get }
    /// 内容类型
    var contentType: KBHTTP.ContentType { get }
    /// 请求头
    var headers: [String: String]? { get }
    /// 是否阻塞其他请求
    var isBlockOtherRequests: Bool { get }
    
    /// 请求接口
    /// - Parameters:
    ///   - parameters: 请求参数
    ///   - completionHandler: 完成的处理
    @discardableResult
    func request(with parameters: RequestParameters?,
                 completionHandler: @escaping ((Result<ResponseValue, ResponseError>) -> Void)) -> KBHTTP.Request
}

public extension RequestInterface {
    
    /// 内容类型
    var contentType: KBHTTP.ContentType { .urlencoded }
    
    /// 默认请求头
    var headers: [String: String]? { nil }
    
    /// 是否阻塞其他请求，默认不阻塞
    var isBlockOtherRequests: Bool { false }
}


// MARK: - UploadInterface

/// 上传接口
public protocol UploadInterface {
    
    /// 响应错误
    associatedtype ResponseError: InterfaceError
    /// 响应值
    associatedtype ResponseValue
    
    /// 请求方式
    var method: KBHTTP.Request.Method { get }
    /// 请求的URL
    var url: URL { get }
    /// 请求头
    var headers: [String: String]? { get }
    /// 是否阻塞其他请求
    var isBlockOtherRequests: Bool { get }
    
    /// 上传文件
    /// - Parameters:
    ///   - content: 上传的内容
    ///   - completionHandler: 完成的处理
    @discardableResult
    func upload(_ content: KBHTTP.Request.Content,
                contentType: KBHTTP.ContentType,
                completionHandler: @escaping ((Result<ResponseValue, ResponseError>) -> Void)) -> KBHTTP.Request
}

public extension UploadInterface {
    
    /// 请求方式
    var method: KBHTTP.Request.Method { .post }
    
    /// 默认请求头
    var headers: [String: String]? { nil }
    
    /// 是否阻塞其他请求，默认不阻塞
    var isBlockOtherRequests: Bool { false }
}


// MARK: - InterfaceError

/// 接口错误定义的约束
public protocol InterfaceError: Swift.Error {
    var underlying: Swift.Error? { get }
    init(_ error: Swift.Error)
}
