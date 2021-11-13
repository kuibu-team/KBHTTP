//
//  AlamofireRequestSender.swift
//  KBHTTP
//
//  Created by DancewithPeng on 2021/10/29.
//

import Foundation
import Alamofire

/// Alamofire的请求发送器，用于定义请求具体行为
public class AlamofireRequestSender: KBHTTP.RequestSender {
    
    /// 此Sender已发送请求，允许使用同一个Sender发送多个请求
    public var sendedRequests: [KBHTTP.Request: Alamofire.Request] = [:]
    
    /// dump响应的内容，建议在Debug模式下开启，方便调试，在Release模式下关闭
    public var dumpResponse: Bool
    
    /// dump时，是否解码内容，默认事false
    public var dumpDecodeContent: Bool
    
    /// AF请求的会话
    public var session: Alamofire.Session
    
    
    // MARK: - Interface Methods
    
    /// 初始化方法
    public init(session: Alamofire.Session, dumpResponse: Bool = false, dumpDecodeContent: Bool = false) {
        self.session = session
        self.dumpResponse = dumpResponse
        self.dumpDecodeContent = false
    }

    /// 发送请求
    public func send(request: KBHTTP.Request,
                     completionHandler: @escaping ((Result<KBHTTP.Response, Swift.Error>) -> Void)) throws {

        // 定义响应的处理
        let responseHandler: (AFDataResponse<Data?>) -> Void = { [weak self] response in
                                    
            defer {
                self?.sendedRequests.removeValue(forKey: request)
            }
            
            if self?.dumpResponse == true {
                self?.dump(response)
            }

            switch response.result {
            case let .success(data):
                guard let urlResponse = response.response else {
                    completionHandler(.failure(Error.noResponse))
                    return
                }

                guard let urlRequest = response.request else {
                    completionHandler(.failure(Error.noRequest))
                    return
                }
                
                guard (200...299) ~= urlResponse.statusCode else {
                    completionHandler(.failure(Error(responseStatusCode: urlResponse.statusCode)))
                    return
                }

                let httpResponse = KBHTTP.Response(urlResponse: urlResponse,
                                                   urlRequest: urlRequest,
                                                   data: data)
                completionHandler(.success(httpResponse))
            case let .failure(error):
                completionHandler(.failure(Error.requestError(error)))
            }
        }
        
        if request.content == nil {
            // 数据请求
            try dataRequest(request, responseHandler: responseHandler)
        } else {
            // 文件上传
            try fileUpload(request, responseHandler: responseHandler)
        }
    }
    
    /// 取消请求
    public func cancel(request: KBHTTP.Request) throws {
        sendedRequests[request]?.cancel()
        sendedRequests.removeValue(forKey: request)
    }
    
    
    // MARK: - Helper Methods
    
    /// 数据请求
    private func dataRequest(_ request: KBHTTP.Request,
                     responseHandler: @escaping ((AFDataResponse<Data?>) -> Void)) throws {
        
        let encoding: ParameterEncoding
        switch request.contentType {
        case .urlencoded:
            encoding = URLEncoding.default
        case .json:
            encoding = JSONEncoding.default
        default:
            throw Error.invalidContentType(request.contentType, request.parameters, request.content)
        }
                
        self.sendedRequests[request] =
        self.session.request(request.url,
                             method: HTTPMethod(rawValue: request.method.rawValue),
                             parameters: request.parameters,
                             encoding: encoding,
                             headers: HTTPHeaders(request.finalHeaders ?? [:]),
                             interceptor: nil,
                             requestModifier: nil)
            .response(completionHandler: responseHandler)
    }
    
    /// 文件上传
    private func fileUpload(_ request: KBHTTP.Request,
                    responseHandler: @escaping ((AFDataResponse<Data?>) -> Void)) throws {
        
        guard let content = request.content else {
            throw Error.invalidContentType(request.contentType, request.parameters, request.content)
        }
        
        var headers = HTTPHeaders(request.finalHeaders ?? [:])
        
        // 如果请求中没有指定Content-Type请求头，则根据request.contentType来添加
        if !headers.contains(where: { $0.name.caseInsensitiveCompare("Content-Type") == .orderedSame }) {
            headers.update(HTTPHeader.contentType(request.contentType.description))
        }
        
        switch content {
        case .data(let data):
            // 数据内容
            self.sendedRequests[request] =
            self.session.upload(data,
                                to: request.url,
                                method: HTTPMethod(rawValue: request.method.rawValue),
                                headers: headers,
                                interceptor: nil,
                                fileManager: .default,
                                requestModifier: nil)
                .response(completionHandler: responseHandler)
        case .file(let fileURL):
            // 文件内容
            self.sendedRequests[request] =
            self.session.upload(fileURL,
                                to: request.url,
                                method: HTTPMethod(rawValue: request.method.rawValue),
                                headers: headers,
                                interceptor: nil,
                                fileManager: .default,
                                requestModifier: nil)
                .response(completionHandler: responseHandler)
        }
    }
    
    /// 打印响应内容，用于调试
    private func dump(_ response: AFDataResponse<Data?>) {
        if let urlResponse = response.response,
           let urlRequest = response.request,
           let data = response.data {
            let requestDumpText = urlRequest.dump(with: self.session.session, decodeContent: self.dumpDecodeContent)
            let responseDumpText = urlResponse.dump(with: data, decodeContent: self.dumpDecodeContent)
            let dumpText = """
                           
                           >>> AF Request >>>
                           
                           \(requestDumpText)
                           <<< AF Response <<<
                           
                           \(responseDumpText)
                           >>> End <<<
                           
                           """
            print(dumpText)
        }
    }
}

public extension AlamofireRequestSender {
    
    /// 请求发送器的错误
    enum Error: Swift.Error {
        
        /// 没有请求
        case noRequest
        
        /// 没有响应
        case noResponse
        
        /// 无效的内容类型
        case invalidContentType(KBHTTP.ContentType, [String: Any]?, KBHTTP.Request.Content?)
        
        /// 请求错误
        case requestError(AFError)
        
        /// 响应错误
        case responseError(Int, String)
        
        init(responseStatusCode statusCode: Int) {
            self = .responseError(statusCode, HTTPURLResponse.localizedString(forStatusCode: statusCode))
        }
    }
}

