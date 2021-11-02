//
//  RequestSchedulerTests.swift
//  KBHTTPTests
//
//  Created by DancewithPeng on 2021/10/26.
//

import XCTest
import KBHTTP

class RequestSchedulerTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// 测试请求依赖
    func testRequestDependency() throws {
        
        let expectation = XCTestExpectation(description: "testRequestDependency")
        let group = DispatchGroup()

        group.enter()
        let sender5s = RequestDependencySender(blockedTime: 5) {
            print("i am 5s sender")
            group.leave()
        }

        group.enter()
        let sender4s = RequestDependencySender(blockedTime: 4) {
            print("i am 4s sender")
            group.leave()
        }

        group.enter()
        let sender3s = RequestDependencySender(blockedTime: 3) {
            print("i am 3s sender")
            group.leave()
        }

        group.notify(queue: .global()) {
            expectation.fulfill()
        }

        let request5s = Request(method: .get,
                                url: URL(string: "https://www.baidu.com")!,
                                sender: sender5s,
                                isBlockOtherRequests: true,
                                completionHandler: nil)

        let request4s = Request(method: .get,
                                url: URL(string: "https://www.baidu.com")!,
                                sender: sender4s,
                                isBlockOtherRequests: false,
                                completionHandler: nil)

        let request3s = Request(method: .get,
                                url: URL(string: "https://www.baidu.com")!,
                                sender: sender3s,
                                isBlockOtherRequests: false,
                                completionHandler: nil)

        RequestScheduler.default.add(request: request3s)
        RequestScheduler.default.add(request: request5s)
        RequestScheduler.default.add(request: request4s)

        wait(for: [expectation], timeout: 10)
    }
    
    /// 测试线程安全
    func testThreadSafety() {
        
        let expectation = XCTestExpectation(description: "testThreadSafety")
        let group = DispatchGroup()

        DispatchQueue.concurrentPerform(iterations: 10) { index in

            group.enter()
            let sender = RequestDependencySender(blockedTime: TimeInterval.random(in: 1...3)) {
                group.leave()
            }

            let request = Request(method: .get,
                                  url: URL(string: "https://www.baidu.com")!,
                                  sender: sender,
                                  isBlockOtherRequests: false,
                                  completionHandler: nil)

            // 测试并发时，`add(request:)`方法的线程安全
            RequestScheduler.default.add(request: request)
        }

        group.notify(queue: .global()) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.2)
    }
}

extension RequestSchedulerTests {
    
    class RequestDependencySender: RequestSender {

        var blockedTime: TimeInterval
        var completionHandler: (() -> Void)?

        init(blockedTime: TimeInterval, completionHandler: (() -> Void)?) {
            self.blockedTime = blockedTime
            self.completionHandler = completionHandler
        }

        func send(request: Request,
                  completionHandler: @escaping ((Result<Response, Error>) -> Void)) throws {

            DispatchQueue.global().asyncAfter(deadline: .now() + blockedTime) {

                // request completion
                let mockResponse = HTTPURLResponse(url: request.url,
                                                   statusCode: 200,
                                                   httpVersion: "1.1",
                                                   headerFields: nil)!
                let mockRequest = URLRequest(url: request.url,
                                             cachePolicy: .useProtocolCachePolicy,
                                             timeoutInterval: 10)

                completionHandler(.success(Response(urlResponse: mockResponse, urlRequest: mockRequest, data: nil)))

                self.completionHandler?()
                self.completionHandler = nil
            }
        }
        
        func cancel(request: Request) throws {
            
        }

        deinit {
            print("RequestDependencySender dead")
        }
    }
}
