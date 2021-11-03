//
//  HTTPURLResponseDump.swift
//  KBHTTP
//
//  Created by DancewithPeng on 2021/11/2.
//

import Foundation

extension HTTPURLResponse {
    
    public func dump(with data: Data, decodeContent: Bool = false) -> String {
        var result = "\(self.statusCode)"
        if self.statusCode == 200 {
            result.append(" OK")
        } else {
            result.append(" \(HTTPURLResponse.localizedString(forStatusCode: self.statusCode))")
        }
                
        result.append("\n")
        
        for (headerName, headerValue) in self.allHeaderFields {
            result.append("\(headerName): \(headerValue) \n")
        }
        
        result.append("\n")

        let contentType = self.allHeaderFields["Content-Type"] as? String
        if decodeContent,
           contentType?.contains("application/json") == true,
           let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            result.append("\(json)")
        } else {
            if let text = String(data: data, encoding: .utf8) {
                result.append(text)
            } else {
                result.append(data.base64EncodedString())
            }
        }
        
        result.append("\n")
        
        return result
    }
    
    public func fullDump(with request: URLRequest, session: URLSession?, data: Data, decodeContent: Bool = false) -> String {
        let requestDumpText = request.dump(with: session, decodeContent: decodeContent)
        let responseDumpText = self.dump(with: data, decodeContent: decodeContent)
        return "\(requestDumpText)\n\n\(responseDumpText)"
    }
}
