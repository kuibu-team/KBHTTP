//
//  AlamofireInterfaceResponseError.swift
//  KBHTTP
//
//  Created by DancewithPeng on 2021/11/10.
//

import Foundation

/// Alamofire接口错误
public enum AlamofireInterfaceError: Swift.Error {
    
    /// 不正确的响应值类型
    case incorrectResponseValueType(Any.Type, Any?)
    
    /// 请求错误
    case requestError(KBHTTP.Request.Error)
}

/// 接口响应错误
public protocol AlamofireInterfaceResponseError: InterfaceResponseError {
    init(_ interfaceError: KBHTTP.AlamofireInterfaceError)
}

extension AlamofireInterfaceResponseError {
    public init(_ requestError: KBHTTP.Request.Error) {
        self.init(AlamofireInterfaceError.requestError(requestError))
    }
}
