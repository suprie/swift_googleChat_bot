import XCTest
import AsyncHTTPClient

class AsyncHTTPTests: XCTestCase {
	func testGet() {
        let expectation = XCTestExpectation(description: "Get from swift.org")

        let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        defer {
            try? httpClient.syncShutdown()
        }

        httpClient.post(url: "https://swift.org")
            .whenComplete { result in
                switch result {
                case .failure(let error):
                    XCTAssert(false, "failure")
                case .success(let response):
                    if response.status == .ok {
                        XCTAssert(true)
                    } else {
                        XCTAssert(false, "not ok")
                    }
                }
                expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
	}
    func testPost() {
        let url = "http://dummy.restapiexample.com/api/v1/create"
        let dataString = "{\"name\":\"test\",\"salary\":\"123\",\"age\":\"23\"}"

        let expectation = XCTestExpectation(description: "Post restapi")

        let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        defer {
            try? httpClient.syncShutdown()
        }

        var request = try! HTTPClient.Request(url: url, method: .POST)
        request.headers.add(name: "Content-Type", value: "application/json")
        request.body = .string(dataString)

        httpClient.execute(request: request).whenComplete { result in
            switch result {
                case .failure(let error):
                    XCTAssert(false, "failure post")
                case .success(let response):
                    if response.status == .ok {
                        XCTAssert(true)
                    } else {
                        XCTAssert(false, "post not ok")
                    }
                }
                expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}