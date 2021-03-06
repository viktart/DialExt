//
//  DLGAsyncOperation.swift
//  DialExt
//
//  Created by Aleksei Gordeev on 12/04/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

public enum DLGAsyncOperationResult<ResultData> {
    case success(ResultData?)
    case failure(Error?)
    case cancelled
    case undefined(Any?)
}

public enum DLGOperationState {
    case idle
    case executing
    case finished
    
    var operationKey: String? {
        
        // Do not use #keyPath here, because swift 3.1 has bug with operation's keyPaths.
        // https://github.com/postmates/PMKVObserver/issues/15
        
        switch self {
        case .executing: return "isExecuting"
        case .finished: return "isFinished"
        default: return nil
        }
    }
}

/**
 A basic abstract async operation for subclassing
 
 onDidFinish() called *before* finishing operation.
 Be careful, the completion block may be called on other thread than onDidFinish().
 */
open class DLGAsyncOperation<ResultData>: Operation {
    
    public var onDidFinish:((DLGAsyncOperationResult<ResultData>) -> ())?
    
    open override var isFinished: Bool {
        return self.state == .finished
    }
    
    open override var isExecuting: Bool {
        return self.state == .executing
    }
    
    open override var isAsynchronous: Bool {
        return true
    }
    
    open override func start() {
        self.updateState(.executing)
        onDidStart()
    }
    
    // Subclassing: Call
    
    // Subclasses should call this method to change state.
    public func updateState(_ state: DLGOperationState) {
        self.state = state
    }
    
    // Thread-safe is in your responsibility.
    public func finish(result: DLGAsyncOperationResult<ResultData>) {
        onDidFinish?(result)
        self.updateState(.finished)
    }
    
    public func finishWithFailure(error: Error?) {
        finish(result: DLGAsyncOperationResult.failure(error))
    }
    
    public func finishWithCancel() {
        finish(result: DLGAsyncOperationResult.cancelled)
    }
    
    public func finishIfCancelled() -> Bool {
        guard !self.isCancelled else {
            finishWithCancel()
            return true
        }
        return false
    }
    
    // Subclassing: Override
    
    /**
     Override this method instead of 'start' or 'main'.
     */
    open func onDidStart() {
        
    }
    
    // Private
    
    // TODO: Make thread-safe
    private var state: DLGOperationState = .idle {
        willSet {
            if let oldStateWillChangeKey = state.operationKey {
                self.willChangeValue(forKey: oldStateWillChangeKey)
            }
            if let newStateWillChangeKey = newValue.operationKey {
                self.willChangeValue(forKey: newStateWillChangeKey)
            }
        }
        
        didSet {
            if let newStateDidChangeKey = state.operationKey {
                self.didChangeValue(forKey: newStateDidChangeKey)
            }
            if let oldStateDidChangeKey = oldValue.operationKey {
                self.didChangeValue(forKey: oldStateDidChangeKey)
            }
        }
    }
}
