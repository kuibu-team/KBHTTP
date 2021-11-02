//
//  RequestScheduler.swift
//  KBHTTP
//
//  Created by DancewithPeng on 2021/10/26.
//

import Foundation

/// 请求调度器
public class RequestScheduler {
    
    /// 阻塞队列
    private let blockedQueue: OperationQueue
    /// 非阻塞队列
    private let nonBlockedQueue: OperationQueue
    
    /// 同步队列，用于保证`add(request:)`方法的线程安全
    private let threadSafetyQueue = DispatchQueue(label: "KBHTTP.RequestScheduler.threadSafetyQueue")
    
    public init() {
        self.blockedQueue                             = OperationQueue()
        self.blockedQueue.name                        = "KBHTTP.RequestScheduler.blockedQueue"
        self.blockedQueue.maxConcurrentOperationCount = 1
        
        self.nonBlockedQueue      = OperationQueue()
        self.nonBlockedQueue.name = "KBHTTP.RequestScheduler.nonBlockedQueue"
    }
    
    /// 添加请求，线程安全
    public func add(request: Request) {

        threadSafetyQueue.async { [weak self] in

            guard let weakSelf = self else {
                return
            }

            if request.isBlockOtherRequests {
                for nonBlockedRequest in weakSelf.nonBlockedQueue.operations {
                    if nonBlockedRequest.isFinished || nonBlockedRequest.isCancelled || nonBlockedRequest.isExecuting {
                        continue
                    }
                    nonBlockedRequest.addDependency(request)
                }
                weakSelf.blockedQueue.addOperation(request)
            } else {
                for blockedRequest in weakSelf.blockedQueue.operations {
                    request.addDependency(blockedRequest)
                }
                weakSelf.nonBlockedQueue.addOperation(request)
            }
        }
    }
}

extension RequestScheduler {
    
    /// 单例
    public static let `default` = RequestScheduler()
}
