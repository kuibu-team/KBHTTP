//
//  ErrorTests.swift
//  KBHTTPTests
//
//  Created by DancewithPeng on 2021/11/9.
//

import XCTest
import UIKit
import KBHTTP
import Alamofire

class ErrorTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
        
    func testRequestError() throws {
        
        let expectation = XCTestExpectation(description: "testResponseDump")
        
        ErrorTestGETInterface().request(with: .init(name: "李四", age: 18)) { result in
            
            defer {
                expectation.fulfill()
            }
            
            switch result {
            case .success(let value):
                print(value)
            case .failure(let error):
                // request(sender(af))
                print(error)
            }
        }
        
        wait(for: [expectation], timeout: 20)
    }
}

class ErrorTestGETInterface: KBDemoRequestInterface {
    
    var method: KBHTTP.Request.Method = .get
    var url: URL = URL(string: "http://localhost:8080/delay")!
    
    var session: Session {
        let config = AF.sessionConfiguration
        config.timeoutIntervalForRequest = 5
        config.timeoutIntervalForResource = 5
        return Session(configuration: config)
    }
    
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
