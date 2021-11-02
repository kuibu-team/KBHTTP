//
//  AlamofireRequestInterfaceTests.swift
//  KBHTTPTests
//
//  Created by DancewithPeng on 2021/11/1.
//

import XCTest
import KBHTTP


class AlamofireRequestInterfaceTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDemoGET() throws {
        let exception = XCTestExpectation(description: "testDemoGET")
        
        DemoGETInterface().request(with: .init(name: "张三", age: 18)) { result in
            switch result {
            case .success(let value):
                print(value)
                exception.fulfill()
            case .failure(let error):
                print(error)
                XCTAssert(false, error.localizedDescription)
            }
        }
        
        wait(for: [exception], timeout: 10)
    }
    
    func testDemoPOST() throws {
        let exception = XCTestExpectation(description: "testDemoPOST")
        
        DemoPOSTInterface().request(with: .init(name: "张三", age: 18)) { result in
            switch result {
            case .success(let value):
                print(value)
                exception.fulfill()
            case .failure(let error):
                print(error)
                XCTAssert(false, error.localizedDescription)
            }
        }
        
        wait(for: [exception], timeout: 10)
    }
    
    func testJSON() throws {
        
        let exception = XCTestExpectation(description: "testDemoPOST")
        
        DemoJSONInterface().request(with: .init(name: "张三", age: 18)) { result in
            switch result {
            case .success(let value):
                print(value)
                exception.fulfill()
            case .failure(let error):
                print(error)
                XCTAssert(false, error.localizedDescription)
            }
        }
        
        wait(for: [exception], timeout: 10)
    }
    
    func testFileUpload() throws {
        
        let exception = XCTestExpectation(description: "testFileUpload")
        
        let fileURL = URL(fileURLWithPath: "/Users/zhangpeng/Desktop/demo-image.png")
        let data = try Data(contentsOf: fileURL)
        
        FileUploadInterface().upload(.data(data),
                                     contentType: .png) { result in
            switch result {
            case .success(let value):
                print(value)
                exception.fulfill()
            case .failure(let error):
                print(error)
                XCTAssert(false, error.localizedDescription)
            }
        }
        
        wait(for: [exception], timeout: 10)
    }
    
    func testFileStreamUpload() throws {
        
        let exception = XCTestExpectation(description: "testFileStreamUpload")
        
        let fileURL = URL(fileURLWithPath: "/Users/zhangpeng/Desktop/demo-image.png")
        
        FileStreamUploadInterface().upload(.file(fileURL),
                                           contentType: .png) { result in
            switch result {
            case .success(let value):
                print(value)
                exception.fulfill()
            case .failure(let error):
                print(error)
                XCTAssert(false, error.localizedDescription)
            }
        }
        
        wait(for: [exception], timeout: 30)
    }
}

// MARK: - KBDemoInterface

struct KBDemoResponseError: AlamofireRequestInterfaceError, AlamofireUploadInterfaceError {
    
    var code: Int
    var message: String
    
    static var nullResponseValue: DemoGETInterface.ResponseError = .init(code: 100, message: "空数据")
    
    var underlying: Error?
    
    init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
    
    init(_ error: Error) {
        let nserr = error as NSError
        code = nserr.code
        message = error.localizedDescription
        
        self.underlying = error
    }
}

protocol KBDemoRequestInterface: AlamofireRequestInterface where ResponseError == KBDemoResponseError, ResponseValue: Decodable {
    
}

extension KBDemoRequestInterface {
    
    var dynamicHeadersProvider: DynamicHeadersProvider? { nil }
    
    /// 解析响应
    func parse(response: Response) throws -> Any? {
        guard let data = response.data else {
            throw ResponseError.nullResponseValue
        }
        return try JSONDecoder().decode(ResponseValue.self, from: data)
    }
}

protocol KBDemoUploadInterface: AlamofireUploadInterface where ResponseError == KBDemoResponseError, ResponseValue: Decodable {
    
}

extension KBDemoUploadInterface {
    
    var dynamicHeadersProvider: DynamicHeadersProvider? { nil }
    
    /// 解析响应
    func parse(response: Response) throws -> Any? {
        guard let data = response.data else {
            throw ResponseError.nullResponseValue
        }
        return try JSONDecoder().decode(ResponseValue.self, from: data)
    }
}

extension KBDemoRequestInterface {
    var dumpResponse: Bool {
        return true
    }
}

extension KBDemoUploadInterface {
    var dumpResponse: Bool {
        return true
    }
}


// MARK: - DemoGETInterface

class DemoGETInterface: KBDemoRequestInterface {
    
    var method: Request.Method = .get
    var url: URL = URL(string: "http://localhost:8080/kbhttp/urlencoded")!
    
    struct RequestParameters: DictionaryConvertible {
        var name: String
        var age: Int
        
        func asDictionary() throws -> [String : Any]? {
            return [
                "name": name,
                "age": age
            ]
        }
    }
    
    typealias ResponseValue = DemoResponseValue
}

// MARK: - DemoPOSTInterface

class DemoPOSTInterface: KBDemoRequestInterface {
    
    var method: Request.Method = .post
    var url: URL = URL(string: "http://localhost:8080/kbhttp/urlencoded")!
    
    struct RequestParameters: DictionaryConvertible {
        var name: String
        var age: Int
        
        func asDictionary() throws -> [String : Any]? {
            return [
                "name": name,
                "age": age
            ]
        }
    }
    
    typealias ResponseValue = DemoResponseValue
}

// MARK: - DemoPOSTInterface

class DemoJSONInterface: KBDemoRequestInterface {
    
    var method: Request.Method = .post
    var url: URL = URL(string: "http://localhost:8080/kbhttp/json")!
    var contentType: ContentType = .json
    
    struct RequestParameters: DictionaryConvertible {
        var name: String
        var age: Int
        
        func asDictionary() throws -> [String : Any]? {
            return [
                "name": name,
                "age": age
            ]
        }
    }
    
    typealias ResponseValue = DemoResponseValue
}

// MARK: - DemoPOSTInterface

class FileUploadInterface: KBDemoUploadInterface {
    var url: URL = URL(string: "http://localhost:8080/kbhttp/file")!
    typealias ResponseValue = DemoResponseValue
}

class FileStreamUploadInterface: KBDemoUploadInterface {
    var url: URL = URL(string: "http://localhost:8080/kbhttp/file/stream")!
    typealias ResponseValue = DemoResponseValue
}
