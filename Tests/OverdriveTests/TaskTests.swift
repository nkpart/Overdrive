//
//  Tests.swift
//  Tests
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
import TestSupport

@testable import Overdrive

class TaskTests: XCTestCase {
    
    let queue = TaskQueue(qos: .default)
    
    func testIntializedState() {
        let task = SimpleTask()
        XCTAssertEqual(task.state, .initialized, "Task state should be: Initialized")
    }
    
    func testFinishedState() {
        let task = SimpleTask()
        let expectation = self.expectation(description: "Task finished state expecation")
        
        task.onValue { value in
            XCTAssertEqual(task.state, .finished, "Task state should be: Finished")
            expectation.fulfill()
        }
        
        queue.add(task: task)
        
        waitForExpectations(timeout: 0.3) { handlerError in
            print(handlerError)
        }
    }
    
    func testOnValueCompletionBlockValue() {
        let task = SimpleTask()
        
        task
            .onValue { _ in }
            .onError { _ in }
        
        XCTAssertNotNil(task.onValueBlock, "onValue block should be set")
    }
    
    func testOnErrorCompletionBlockValue() {
        let task = SimpleTask()
        
        task
            .onValue { _ in }
            .onError { _ in }
        
        
        XCTAssertNotNil(task.onErrorBlock, "onError block should be set")
    }
    
    func testOnValueBlockExecution() {
        let task = SimpleTask()
        let expectation = self.expectation(description: "Task result value expecation")
        
        task.onValue { value in
            XCTAssertEqual(value, 10, "Task result value should be 10")
            expectation.fulfill()
        }
        
        queue.add(task: task)
        
        waitForExpectations(timeout: 0.1) { handlerError in
            print(handlerError)
        }
    }
    
    func testOnErrorBlockExecution() {
        let task = FailableTask()
        let expectation = self.expectation(description: "Task result error expecation")
        
        task
            .onError { error in
                expectation.fulfill()
            }.onValue { _ in
                XCTFail("onValue: block should not be executed")
        }
        
        queue.add(task: task)
        
        waitForExpectations(timeout: 0.1) { handlerError in
            print(handlerError)
        }
    }
    
    func testTaskEqueue() {
        let task = Task<Int>()
        
        (task as Operation).enqueue()

        /// The moment you call `enqueue()` method, `Foundation.Operation`
        /// KVO observers will check if task is ready for execution. Since
        /// `isReady` property inside `SimpleTask` is not overriden, `state`
        /// will change to `.ready` automatically.
        
        XCTAssertEqual(task.state, .ready)
    }
}
