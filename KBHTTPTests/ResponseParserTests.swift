//
//  ResponseParserTests.swift
//  KBHTTPTests
//
//  Created by DancewithPeng on 2021/10/28.
//

import XCTest
import KBHTTP
import Alamofire

class ResponseParserTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testParser() {
        
        let expectation = XCTestExpectation(description: "XCTestExpectation")

        let alamofireRequestSender = RequestSenderTests.AlamofireRequestSender()

        let request = KBHTTP.Request(method: .get,
                                              url: URL(string: "https://www.baidu.com")!,
                                              sender: alamofireRequestSender,
                                              responseParser: self,
                                              isBlockOtherRequests: false) { request, result in
            defer {
                expectation.fulfill()
            }

            guard case .success(let response) = result else {
                XCTAssert(false, "请求错误")
                return
            }

            print(response)
            print(response.urlRequest)
            print(response.urlResponse)
        }

        KBHTTP.RequestScheduler.default.add(request: request)

        wait(for: [expectation], timeout: 10)
    }
}

extension ResponseParserTests: ResponseParser {
    
    func parse(response: Response) throws -> Any? {
        guard let data = response.data else {
            return nil
        }
        let string = String(data: data, encoding: .utf8)
        return string
    }
}
