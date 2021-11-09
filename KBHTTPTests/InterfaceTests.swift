//
//  InterfaceTests.swift
//  KBHTTPTests
//
//  Created by DancewithPeng on 2021/10/28.
//

import XCTest
import KBHTTP
import Alamofire

class InterfaceTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInterfaceCall() throws {
        
        let expectation = XCTestExpectation(description: "testInterfaceCall")
        
        BaiduPageInterface().request(with: .init(name: "张三", age: 18)) { result in
            
            defer {
                expectation.fulfill()
            }
            
            switch result {
            case .success(let text):
                print("请求成功：\(text)")
            case .failure(let error):
                print("请求失败：\(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10)
    }
}

extension DictionaryConvertible where Self: Encodable {
    
    func asDictionary() -> [String: Any]? {
        return nil
    }
}

protocol MySubInterface: KBHTTP.RequestInterface, KBHTTP.ResponseParser {
    var path: String { get }
}

extension MySubInterface {
    var url: URL {
        return URL(string: "https://www.baidu.com\(path)")!
    }
}

extension MySubInterface {
    
    @discardableResult
    func request(with parameters: RequestParameters?,
                 completionHandler: @escaping ((Result<ResponseValue, ResponseError>) -> Void)) -> KBHTTP.Request {
        
        let request = KBHTTP.Request(method: self.method,
                                     url: self.url,
                                     parameters: try? parameters?.asDictionary(),
                                     sender: RequestSenderTests.AlamofireRequestSender(),
                                     responseParser: self,
                                     isBlockOtherRequests: false) { request, result in
            switch result {
            case .success(let response):
                guard let value = response.value as? ResponseValue else {
                    assertionFailure("please return the correct data type. type is \(ResponseValue.self), value is \(response.value ?? "nil")")
                    return
                }
                completionHandler(.success(value))
            case .failure(let error):
                completionHandler(.failure(ResponseError(error)))
            }
        }
        
        KBHTTP.RequestScheduler.default.add(request: request)
        
        return request
    }
}

class BaiduPageInterface: MySubInterface {
    
    var method: KBHTTP.Request.Method = .get
    var path: String = ""
    var requests: [KBHTTP.Request] = []
    var contentType: KBHTTP.ContentType = .urlencoded
    
    struct RequestParameters: DictionaryConvertible, Encodable {
        var name: String
        var age: Int
    }
    
    typealias ResponseValue = String
    
    enum ResponseError: KBHTTP.InterfaceResponseError {
                        
        case unknown(Swift.Error?)
        case incorrectType
        case parserError(Swift.Error?)
        
        case requestError(Swift.Error)
        case networkError(Swift.Error)
        case parsingError(Swift.Error)
        
        case nullValue
        
        init(networkError: Error) {
            self = .parserError(networkError)
        }
        
        init(requestError: Error) {
            self = .requestError(requestError)
        }
        
        init(parsingError: Error) {
            self = .parsingError(parsingError)
        }
        
        init(_ error: Error) {
            self = .unknown(error)
        }
        
        init(_ requestError: KBHTTP.Request.Error) {
            self = .unknown(requestError)
        }
    }
    
    func parse(response: Response) throws -> Any? {
        guard let data = response.data else {
            throw ResponseError.parserError(nil)
        }
        return String(data: data, encoding: .utf8)
    }
}
