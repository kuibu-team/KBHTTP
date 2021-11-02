//
//  AlamofireRequestSenderTests.swift
//  KBHTTPTests
//
//  Created by DancewithPeng on 2021/10/29.
//

import XCTest
import KBHTTP

class AlamofireRequestSenderTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testURLEncodedGET() throws {
        
        let expectation = XCTestExpectation(description: "AlamofireRequestSenderTests.testURLEncodedGET")
        
        let parameters = DemoRequestParameters(name: "李四", age: 200)
        URLEncodedGETInterface().request(with: parameters) { result in
            defer {
                expectation.fulfill()
            }
            
            switch result {
            case .success(let value):
                let targetValue = DemoResponseValue(code: "100001",
                                                    message: "操作成功",
                                                    name: parameters.name,
                                                    type: "urlEncodedGET",
                                                    age: "\(parameters.age)")
                XCTAssertEqual(targetValue, value)
            case .failure(let error):
                print(error)
                XCTAssert(false, error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testURLEncodedPOST() throws {
        
        let expectation = XCTestExpectation(description: "AlamofireRequestSenderTests.testURLEncodedPOST")
        
        let parameters = DemoRequestParameters(name: "啊哈哈哈", age: 200)
        URLEncodedPOSTInterface().request(with: parameters) { result in
            defer {
                expectation.fulfill()
            }
            
            switch result {
            case .success(let value):
                let targetValue = DemoResponseValue(code: "100002",
                                                    message: "操作成功",
                                                    name: parameters.name,
                                                    type: "urlEncodedPOST",
                                                    age: "\(parameters.age)")
                XCTAssertEqual(targetValue, value)
            case .failure(let error):
                print(error)
                XCTAssert(false, error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testJSONPOST() throws {
        let expectation = XCTestExpectation(description: "AlamofireRequestSenderTests.testJSONPOST")
        
        let parameters = DemoRequestParameters(name: "JSON", age: 200)
        JSONPOSTInterface().request(with: parameters) { result in
            defer {
                expectation.fulfill()
            }
            
            switch result {
            case .success(let value):
                let targetValue = DemoResponseValue(code: "100003",
                                                    message: "操作成功",
                                                    name: parameters.name,
                                                    type: "jsonPOST",
                                                    age: "\(parameters.age)")
                XCTAssertEqual(targetValue, value)
            case .failure(let error):
                print(error)
                XCTAssert(false, error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testSingleFileData() throws {
        
        let expectation = XCTestExpectation(description: "AlamofireRequestSenderTests.testSingleFileData")
        
        let filePath = "/Users/zhangpeng/Desktop/demo-image.png"
        let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
        
        CustomUploadInterface().upload(.data(data),
                                       contentType: .png) { result in
            defer {
                expectation.fulfill()
            }
            
            switch result {
            case .success(let value):
                let targetValue = DemoResponseValue(code: "100004",
                                                    message: "操作成功",
                                                    name: "",
                                                    type: "singleFileUpload",
                                                    age: "")
                XCTAssertEqual(targetValue, value)
            case .failure(let error):
                print(error)
                XCTAssert(false, error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testSingleFileURL() throws {
        
        let expectation = XCTestExpectation(description: "AlamofireRequestSenderTests.testSingleFileURL")
        
        let fileURL = URL(fileURLWithPath: "/Users/zhangpeng/Desktop/demo-image.png")
        
        CustomUploadInterface().upload(.file(fileURL),
                                       contentType: .png) { result in
            defer {
                expectation.fulfill()
            }
            
            switch result {
            case .success(let value):
                let targetValue = DemoResponseValue(code: "100004",
                                                    message: "操作成功",
                                                    name: "",
                                                    type: "singleFileUpload",
                                                    age: "")
                XCTAssertEqual(targetValue, value)
            case .failure(let error):
                print(error)
                XCTAssert(false, error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 30)
    }
    
    // StreamCustomUploadInterface
    func testSingleFileURLStream() throws {
        
        let expectation = XCTestExpectation(description: "AlamofireRequestSenderTests.testSingleFileURLStream")
        
        let fileURL = URL(fileURLWithPath: "/Users/zhangpeng/Desktop/images.jpeg")
        
        StreamCustomUploadInterface().upload(.file(fileURL),
                                             contentType: .jpeg) { result in
            defer {
                expectation.fulfill()
            }
            
            switch result {
            case .success(let value):
                let targetValue = DemoResponseValue(code: "100005",
                                                    message: "操作成功",
                                                    name: "",
                                                    type: "singleFileUpload",
                                                    age: "")
                XCTAssertEqual(targetValue, value)
            case .failure(let error):
                print(error)
                XCTAssert(false, error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 30)
    }
}

class URLEncodedGETInterface: KBHTTP.RequestInterface, KBHTTP.ResponseParser {
    
    var method: KBHTTP.Request.Method { .get }
    var url: URL { URL(string: "http://localhost:8080/kbhttp/urlencoded")! }
    var contentType: KBHTTP.ContentType { .urlencoded }
    
    typealias RequestParameters = DemoRequestParameters
    typealias ResponseValue = DemoResponseValue
    typealias ResponseError = DemoResponseError
    
    @discardableResult
    func request(with parameters: DemoRequestParameters?,
                 completionHandler: @escaping ((Result<DemoResponseValue, DemoResponseError>) -> Void)) -> Request {
        let request = KBHTTP.Request(method: self.method,
                                     url: self.url,
                                     headers: self.headers,
                                     parameters: try? parameters?.asDictionary(),
                                     content: nil,
                                     contentType: self.contentType,
                                     dynamicHeadersProvider: nil,
                                     sender: KBHTTP.AlamofireRequestSender(),
                                     responseParser: self,
                                     isBlockOtherRequests: false) { request, result in
            switch result {
            case .success(let response):
                guard let value = response.value as? ResponseValue else {
                    completionHandler(.failure(.nullValue))
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
    
    func parse(response: Response) throws -> Any? {
        
        guard response.statusCode == 200 else {
            throw ResponseError(code: response.statusCode)
        }
        
        guard let data = response.data else {
            throw ResponseError.nullValue
        }
        
        let result = try JSONDecoder().decode(DemoResponseValue.self, from: data)
        return result
    }
}

class URLEncodedPOSTInterface: URLEncodedGETInterface {
    override var method: Request.Method {
        return .post
    }
}

class JSONPOSTInterface: URLEncodedPOSTInterface {
    override var method: Request.Method {
        return .post
    }
    
    override var url: URL { URL(string: "http://localhost:8080/kbhttp/json")! }
    
    override var contentType: KBHTTP.ContentType { .json }
}

class CustomUploadInterface: KBHTTP.UploadInterface, KBHTTP.ResponseParser {

    var url: URL { URL(string: "http://localhost:8080/kbhttp/file")! }
    
    typealias ResponseValue = DemoResponseValue
    typealias ResponseError = DemoResponseError
    
    @discardableResult
    func upload(_ content: Request.Content,
                contentType: ContentType,
                completionHandler: @escaping ((Result<DemoResponseValue, DemoResponseError>) -> Void)) -> Request {
        
        let request = KBHTTP.Request(method: .post,
                                     url: self.url,
                                     headers: self.headers,
                                     parameters: nil,
                                     content: content,
                                     contentType: contentType,
                                     dynamicHeadersProvider: nil,
                                     sender: KBHTTP.AlamofireRequestSender(),
                                     responseParser: self,
                                     isBlockOtherRequests: false) { request, result in
            switch result {
            case .success(let response):
                guard let value = response.value as? ResponseValue else {
                    completionHandler(.failure(.nullValue))
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
    
    func parse(response: Response) throws -> Any? {
        
        guard response.statusCode == 200 else {
            throw ResponseError(code: response.statusCode)
        }
        
        guard let data = response.data else {
            throw ResponseError.nullValue
        }
        
        let result = try JSONDecoder().decode(DemoResponseValue.self, from: data)
        return result
    }
}

class StreamCustomUploadInterface: CustomUploadInterface {
    override var url: URL { URL(string: "http://localhost:8080/kbhttp/file/stream")! }
}

struct DemoResponseError: KBHTTP.InterfaceError {
    
    var code: Int = 0
                    
    var underlying: Error?
    
    init(_ error: Error) {
        self.underlying = error
    }
    
    init() {
        self.underlying = nil
    }
    
    init(code: Int) {
        self.code = code
    }
    
    static let nullValue = DemoResponseError()
}

struct DemoRequestParameters: DictionaryConvertible {
    var name: String
    var age: Int
    
    func asDictionary() throws -> [String : Any]? {
        return [
            "name": name,
            "age": age
        ]
    }
}

struct DemoResponseValue: Decodable, Equatable {
    var code: String
    var message: String
    var name: String
    var type: String
    var age: String
}
