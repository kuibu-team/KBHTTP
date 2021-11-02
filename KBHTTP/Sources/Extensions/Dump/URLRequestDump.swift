//
//  URLRequestDump.swift
//  KBHTTP
//
//  Created by DancewithPeng on 2021/11/1.
//

import Foundation

extension URLRequest {
    
    public func dump(with session: URLSession? = nil, decodeContent: Bool = false) -> String {
        var result = "\(self.httpMethod ?? "GET") \(self.url?.path ?? "/")"
        if let query = self.url?.query {
            result.append("?\(query)")
        }
        
        result.append("\n")
        
        if let requestHeaders = self.allHTTPHeaderFields {
            for (headerName, headerValue) in requestHeaders {
                result.append("\(headerName): \(headerValue) \n")
            }
        }
        
        if let sessionHeaders = session?.configuration.httpAdditionalHeaders {
            for (headerName, headerValue) in sessionHeaders {
                result.append("\(headerName): \(headerValue) \n")
            }
        }
        
        result.append("\n")
        
        if self.httpBodyStream != nil {
            result.append("<stream...>")
            result.append("\n")
        } else if let bodyData = self.httpBody {
            
            if decodeContent,
               self.value(forHTTPHeaderField: "Content-Type")?.contains(KBHTTP.ContentType.json.description) == true,
               let json = try? JSONSerialization.jsonObject(with: bodyData, options: []) {
                result.append("\(json)")
            } else {
                if let bodyText = String(data: bodyData, encoding: .utf8) {
                    result.append(bodyText)
                } else {
                    result.append(bodyData.base64EncodedString())
                }
            }
            
            result.append("\n")
        } else {
            result.append("<null body>")
            result.append("\n")
        }
        
        return result
    }
}
