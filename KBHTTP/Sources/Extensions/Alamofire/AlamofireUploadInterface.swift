//
//  AlamofireUploadInterface.swift
//  KBHTTP
//
//  Created by DancewithPeng on 2021/11/1.
//

import Foundation
import Alamofire

/// Alamofire的上传接口
public protocol AlamofireUploadInterface: KBHTTP.UploadInterface, KBHTTP.ResponseParser {
    
    /// 动态头部提供者
    var dynamicHeadersProvider: DynamicHeadersProvider? { get }
    
    /// 是否dump响应内容，用于调试，建议在Debug模式下开启，方便调试，在Release模式下关闭
    var dumpResponse: Bool { get }
    
    /// 请求的会话
    var session: Alamofire.Session { get }
    
    /// 请求调度器
    var requestScheduler: KBHTTP.RequestScheduler { get }
}

// MARK: - upload()方法的默认实现
public extension AlamofireUploadInterface {
    
    @discardableResult
    func upload(_ content: Request.Content,
                contentType: ContentType,
                completionHandler: @escaping ((Result<ResponseValue, ResponseError>) -> Void)) -> Request {
        
        let request = KBHTTP.Request(method: self.method,
                                     url: self.url,
                                     headers: self.headers,
                                     parameters: nil,
                                     content: content,
                                     contentType: contentType,
                                     dynamicHeadersProvider: self.dynamicHeadersProvider,
                                     sender: KBHTTP.AlamofireRequestSender(session: self.session, dumpResponse: self.dumpResponse),
                                     responseParser: self,
                                     isBlockOtherRequests: self.isBlockOtherRequests) { request, result in
            switch result {
            case .success(let response):
                guard let value = response.value as? ResponseValue else {
                    assertionFailure("please return the correct data type. received type: \(ResponseValue.self), received value: \(response.value ?? "nil")")
                    return
                }
                completionHandler(.success(value))
            case .failure(let error):
                completionHandler(.failure(ResponseError(error)))
            }
        }
        
        self.requestScheduler.add(request: request)
        
        return request
    }
}
