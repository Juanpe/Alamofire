//
//  BaseTestCase.swift
//
//  Copyright (c) 2014-2018 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Alamofire
import Foundation
import XCTest

class BaseTestCase: XCTestCase {
    let timeout: TimeInterval = 5

    static var testDirectoryURL: URL { return FileManager.temporaryDirectoryURL.appendingPathComponent("org.alamofire.tests") }
    var testDirectoryURL: URL { return BaseTestCase.testDirectoryURL }

    override func setUp() {
        super.setUp()

        FileManager.removeAllItemsInsideDirectory(at: testDirectoryURL)
        FileManager.createDirectory(at: testDirectoryURL)
    }

    func url(forResource fileName: String, withExtension ext: String) -> URL {
        let bundle = Bundle(for: BaseTestCase.self)
        return bundle.url(forResource: fileName, withExtension: ext)!
    }

    func assertErrorIsAFError(_ error: Error?,
                              file: StaticString = #file,
                              line: UInt = #line,
                              evaluation: (_ error: AFError) -> Void) {
        guard let error = error?.asAFError else {
            XCTFail("error is not an AFError", file: file, line: line)
            return
        }

        evaluation(error)
    }

    func assertErrorIsServerTrustEvaluationError(_ error: Error?, file: StaticString = #file, line: UInt = #line, evaluation: (_ reason: AFError.ServerTrustFailureReason) -> Void) {
        assertErrorIsAFError(error, file: file, line: line) { error in
            guard case let .serverTrustEvaluationFailed(reason) = error else {
                XCTFail("error is not .serverTrustEvaluationFailed", file: file, line: line)
                return
            }

            evaluation(reason)
        }
    }

    /// Runs assertions on a particular `DispatchQueue`.
    ///
    /// - Parameters:
    ///   - queue: The `DispatchQueue` on which to run the assertions.
    ///   - assertions: Closure containing assertions to run
    func assert(on queue: DispatchQueue, assertions: @escaping () -> Void) {
        let expect = expectation(description: "all assertions are complete")

        queue.async {
            assertions()
            expect.fulfill()
        }

        waitForExpectations(timeout: timeout)
    }
}
