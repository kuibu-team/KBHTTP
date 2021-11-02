//
//  DumpTests.swift
//  KBHTTPTests
//
//  Created by DancewithPeng on 2021/11/1.
//

import XCTest
import KBHTTP
import Alamofire

class DumpTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testRequestDump() throws {
        
        let params = RequestParameters(name: "张三", age: "18")
        
        var request = URLRequest(url: URL(string: "http://localhost:8080/kbhttp/urlencoded")!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(params)
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        print(request.dump(with: AF.session))
    }
    
    func testResponseDump() throws {
        
        let expectation = XCTestExpectation(description: "testResponseDump")
        
        let params = RequestParameters(name: "张三", age: "18")
        
        var request = URLRequest(url: URL(string: "http://localhost:8080/kbhttp/urlencoded")!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(params)
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            defer {
                expectation.fulfill()
            }
            
            guard let response = response as? HTTPURLResponse, let data = data else {
                return
            }

            print(response.dump(with: data))
        }.resume()
        
        wait(for: [expectation], timeout: 30)
    }
    
    func testFullDump() throws {
        
        let expectation = XCTestExpectation(description: "testResponseDump")
        
        let params = RequestParameters(name: "张三", age: "18")
        
        var request = URLRequest(url: URL(string: "http://localhost:8080/kbhttp/urlencoded")!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(params)
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            defer {
                expectation.fulfill()
            }
            
            guard let response = response as? HTTPURLResponse, let data = data else {
                return
            }

            print(response.fullDump(with: request, session: URLSession.shared, data: data))
            
        }.resume()
        
        wait(for: [expectation], timeout: 30)
    }
    
    func testRequestDumpDecode() throws {
        
        let params = RequestParameters(name: "张三", age: "18")
        
        var request = URLRequest(url: URL(string: "http://localhost:8080/kbhttp/urlencoded")!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(params)
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        print(request.dump(with: AF.session, decodeContent: true))
    }
    
    func testResponseDumpDecode() throws {
        
        let expectation = XCTestExpectation(description: "testResponseDump")
        
        let params = RequestParameters(name: "张三", age: "18")
        
        var request = URLRequest(url: URL(string: "http://localhost:8080/kbhttp/urlencoded")!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(params)
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            defer {
                expectation.fulfill()
            }
            
            guard let response = response as? HTTPURLResponse, let data = data else {
                return
            }

            print(response.dump(with: data, decodeContent: true))
        }.resume()
        
        wait(for: [expectation], timeout: 30)
    }
    
    func testFullDumpDecode() throws {
        
        let expectation = XCTestExpectation(description: "testResponseDump")
        
        let params = RequestParameters(name: "张三", age: "18")
        
        var request = URLRequest(url: URL(string: "http://localhost:8080/kbhttp/urlencoded")!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(params)
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            defer {
                expectation.fulfill()
            }
            
            guard let response = response as? HTTPURLResponse, let data = data else {
                return
            }

            print(response.fullDump(with: request, session: URLSession.shared, data: data, decodeContent: true))
            
        }.resume()
        
        wait(for: [expectation], timeout: 30)
    }
}

struct RequestParameters: Encodable {
    var name: String
    var age: String
}
