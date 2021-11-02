//
//  AlamofireRequestInterface.swift
//  KBHTTP
//
//  Created by DancewithPeng on 2021/10/29.
//

import Foundation
import Alamofire

/// Alamofire的请求接口
public protocol AlamofireRequestInterface: KBHTTP.RequestInterface, KBHTTP.ResponseParser where ResponseError: AlamofireRequestInterfaceError {
    
    /// 动态头部提供者
    var dynamicHeadersProvider: DynamicHeadersProvider? { get }
    
    /// 是否dump响应内容，用于调试，建议在Debug模式下开启，方便调试，在Release模式下关闭
    var dumpResponse: Bool { get }
}

// MARK: - request()方法的默认实现
public extension AlamofireRequestInterface {
    
    @discardableResult
    func request(with parameters: RequestParameters?,
                 completionHandler: @escaping ((Result<ResponseValue, ResponseError>) -> Void)) -> Request {
        
        let request = KBHTTP.Request(method: self.method,
                                     url: self.url,
                                     headers: self.headers,
                                     parameters: try? parameters?.asDictionary(),
                                     content: nil,
                                     contentType: self.contentType,
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

/// Alamofire的请求接口错误限制
public protocol AlamofireRequestInterfaceError: InterfaceError {
    
    /// 描述空响应值的错误
    static var nullResponseValue: Self { get }
}
