//
//  RequestSenderTests.swift
//  KBHTTPTests
//
//  Created by DancewithPeng on 2021/10/27.
//

import XCTest
import KBHTTP
import Alamofire

class RequestSenderTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// 测试自定义Sender
    func testCustomSender() {
        
        let expectation = XCTestExpectation(description: "XCTestExpectation")

        let alamofireRequestSender = AlamofireRequestSender()

        let request = KBHTTP.Request(method: .get,
                                              url: URL(string: "http://localhost:8080/kbhttp/urlencoded")!,
                                              sender: alamofireRequestSender,
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

extension RequestSenderTests {
    
    class AlamofireRequestSender: RequestSender {
        
        var sendedRequests: [KBHTTP.Request: Alamofire.Request] = [:]

        func send(request: KBHTTP.Request,
                  completionHandler: @escaping ((Result<KBHTTP.Response, Swift.Error>) -> Void)) throws {

            let responseHandler: (AFDataResponse<Data?>) -> Void = { [weak self] response in
                
                defer {
                    self?.sendedRequests.removeValue(forKey: request)
                }

                switch response.result {
                case let .success(data):
                    guard let urlResponse = response.response else {
                        completionHandler(.failure(Error.noResponse))
                        return
                    }

                    guard let urlRequest = response.request else {
                        completionHandler(.failure(Error.noRequest))
                        return
                    }

                    let mockResponse = KBHTTP.Response(urlResponse: urlResponse,
                                                                urlRequest: urlRequest,
                                                                data: data)
                    completionHandler(.success(mockResponse))
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            }

            guard let parameters = request.parameters else {
                AF.request(request.url,
                           method: HTTPMethod(rawValue: request.method.rawValue),
                           encoding: URLEncoding.default)
                    .response(completionHandler: responseHandler)
                return
            }
            
            sendedRequests[request] =
            AF.request(request.url,
                       method: HTTPMethod(rawValue: request.method.rawValue),
                       parameters: parameters,
                       encoding: URLEncoding.default)
                .response(completionHandler: responseHandler)
        }
        
        func cancel(request: KBHTTP.Request) throws {
            sendedRequests[request]?.cancel()
            sendedRequests.removeValue(forKey: request)
        }
    }
}

extension RequestSenderTests.AlamofireRequestSender {
    enum Error: Swift.Error {
        case noRequest
        case noResponse
    }
}
