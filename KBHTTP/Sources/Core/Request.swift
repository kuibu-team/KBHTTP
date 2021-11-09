//
//  Request.swift
//  KBHTTP
//
//  Created by DancewithPeng on 2021/10/26.
//

import Foundation

/// 请求
public final class Request: Operation {
    
    // MARK: - Request Properties
    
    public var method: Method
    public var url: URL
    public var headers: [String: String]?
    public var parameters: [String: Any]?
    public var content: Content?
    public var contentType: ContentType = .urlencoded
    
    // MARK: - Request Handing Properties
    
    /// 动态头部提供者
    public var dynamicHeadersProvider: DynamicHeadersProvider?
    
    /// 请求发送器
    public var sender: RequestSender?
    
    /// 是否阻塞其他请求
    public var isBlockOtherRequests = false
    
    /// 状态
    public var status: Status = .notRequested
    
    /// 响应解析器
    public var responseParser: ResponseParser?
    
    /// 完成的处理
    private var completionHandler: ((Request, Result<Response, Request.Error>) -> Void)?
    
    
    // MARK: - Interface Methods
    
    /// 初始化方法
    /// - Parameters:
    ///   - method: HTTPMethod
    ///   - url: URL
    ///   - headers: 请求头
    ///   - parameters: 请求参数，会根据contentType和method自动放置于query或者body
    ///   - content: 请求体内容，如果同时存在content和parameters，body应该优先选择content，逻辑由sender实现
    ///   - contentType: 内容类型
    ///   - dynamicHeadersProvider: 动态请求头
    ///   - dynamicParametersProvider: 动态请求参数
    ///   - sender: 请求发送器
    ///   - isBlockOtherRequests: 是否阻塞其他请求
    ///   - completionHandler: 请求完成的处理
    public init(method: Method,
                url: URL,
                headers: [String: String]? = nil,
                parameters: [String: Any]? = nil,
                content: Content? = nil,
                contentType: ContentType = .urlencoded,
                dynamicHeadersProvider: DynamicHeadersProvider? = nil,
                sender: RequestSender? = nil,
                responseParser: ResponseParser? = nil,
                isBlockOtherRequests: Bool = false,
                completionHandler: ((Request, Result<Response, Request.Error>) -> Void)?) {
        
        self.method                 = method
        self.url                    = url
        self.headers                = headers
        self.parameters             = parameters
        self.content                = content
        self.contentType            = contentType
        self.dynamicHeadersProvider = dynamicHeadersProvider
        self.sender                 = sender
        self.responseParser         = responseParser
        self.isBlockOtherRequests   = isBlockOtherRequests
        self.completionHandler      = completionHandler
    }
    
    /// 取消请求
    public override func cancel() {
        super.cancel()
        
        guard let sender = self.sender else {
            self.finishRequest(.failure(.cancel))
            return
        }
        
        do {
            try sender.cancel(request: self)
            self.finishRequest(.failure(.cancel))
        } catch {
            self.finishRequest(.failure(.senderError(error)))
        }
    }
    
    
    // MARK: - Operation Hooks
    
    var innerConcurrent = false
    var innerExecuting = false
    var innerFinished = false
    
    public override func start() {
        
        guard isCancelled == false, isExecuting == false else {
            return
        }
        
        willChangeValue(for: \Request.isExecuting)
        innerExecuting = true
        didChangeValue(for: \Request.isExecuting)
        
        guard let sender = sender else {
            finishRequest(.failure(.noSender))
            return
        }
        
        status = .requesting
        
        do {
            try sender.send(request: self) { [weak self] result in
                switch result {
                case let .success(response):
                    do {
                        if let responseParser = self?.responseParser {
                            response.value = try responseParser.parse(response: response)
                        }
                        self?.finishRequest(.success(response))
                    } catch {
                        self?.finishRequest(.failure(.parsingError(error)))
                    }
                case let .failure(error):
                    self?.finishRequest(.failure(.senderError(error)))
                }
            }
        } catch {
            finishRequest(.failure(.senderError(error)))
        }
    }
    
    public override var isConcurrent: Bool {
        return innerConcurrent
    }
    
    public override var isExecuting: Bool {
        return innerExecuting
    }
    
    public override var isFinished: Bool {
        return innerFinished
    }
    
    
    // MARK: - Helper Methods
    
    /// 完成请求
    private func finishRequest(_ result: Result<Response, Request.Error>) {
        
        defer {
            self.completionHandler = nil
        }
        
        self.willChangeValue(for: \Request.isFinished)
        self.willChangeValue(for: \Request.isExecuting)
        
        switch result {
        case .failure(let error):
            self.status = .requestFailed(error)
            self.completionHandler?(self, .failure(error))
        case .success(let response):
            self.status = .requestSucceeded(response)
            self.completionHandler?(self, .success(response))
        }

        self.innerExecuting = false
        self.innerFinished = true

        self.didChangeValue(for: \Request.isExecuting)
        self.didChangeValue(for: \Request.isFinished)
    }    
}

// MARK: - Convenience Methods
extension Request {
    
    /// 最终的请求头
    public var finalHeaders: [String: String]? {
        guard let headersProvider = dynamicHeadersProvider,
              let dynamicHeaders = headersProvider.dynamicHeaders else {
                  return self.headers
        }
        
        guard let headers = self.headers else {
            return dynamicHeaders
        }
        
        return dynamicHeaders.merging(headers, uniquingKeysWith: { $1 })
    }
}

// MARK: - Request Sub Types
extension Request {
    
    /// 请求方式
    public enum Method: String {
        case get     = "GET"
        case head    = "HEAD"
        case post    = "POST"
        case put     = "PUT"
        case delete  = "DELETE"
        case connect = "CONNECT"
        case options = "OPTIONS"
        case trace   = "TRACE"
        case patch   = "PATCH"
    }
                
    /// 请求内容，用于上传文件
    public enum Content {
        /// 二进制数据
        case data(Data)
        /// URL
        case file(URL)
    }
    
    /// 请求状态
    public enum Status {
        /// 未请求
        case notRequested
        /// 请求中
        case requesting
        /// 请求失败
        case requestFailed(Request.Error)
        /// 请求成功
        case requestSucceeded(Response)
    }
    
    /// 请求错误
    public enum Error: Swift.Error {
        /// 没有请求发送器
        case noSender
        /// 取消请求
        case cancel
        /// 发送者错误
        case senderError(Swift.Error)
        /// 解析错误
        case parsingError(Swift.Error)
    }        
}

