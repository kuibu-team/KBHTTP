//
//  AlamofireUploadInterface.swift
//  KBHTTP
//
//  Created by DancewithPeng on 2021/11/1.
//

import Foundation

/// Alamofire的上传接口
public protocol AlamofireUploadInterface: KBHTTP.UploadInterface, KBHTTP.ResponseParser where ResponseError: AlamofireUploadInterfaceError {
    
    /// 动态头部提供者
    var dynamicHeadersProvider: DynamicHeadersProvider? { get }
    
    /// 是否dump响应内容，用于调试，建议在Debug模式下开启，方便调试，在Release模式下关闭
    var dumpResponse: Bool { get }
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
                                     sender: KBHTTP.AlamofireRequestSender(dumpResponse: self.dumpResponse),
                                     responseParser: self,
                                     isBlockOtherRequests: self.isBlockOtherRequests) { request, result in
            switch result {
            case .success(let response):
                guard let value = response.value as? ResponseValue else {
                    completionHandler(.failure(.nullResponseValue))
                    return
                }
                completionHandler(.success(value))
            case .failure(let error):
                completionHandler(.failure(.init(error)))
            }
        }
        
        KBHTTP.RequestScheduler.default.add(request: request)
        
        return request
    }
}

/// Alamofire的上传接口错误限制
public protocol AlamofireUploadInterfaceError: InterfaceError {
    
    /// 描述空响应值的错误
    static var nullResponseValue: Self { get }
}
