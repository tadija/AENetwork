import XCTest
@testable import Network

class NetworkTests: XCTestCase {
    
    func testFetchDictionary() {
        let fetchDictionary = expectation(description: "Fetch Dictionary")
        
        guard let url = URL(string: "https://httpbin.org/get")
        else { return }
        
        let request = URLRequest(url: url)
        Network.shared.fetchDictionary(with: request) { (data) in
            do {
                let data = try data()
                debugPrint(data)
                XCTAssert(true)
            } catch {
                XCTAssert(false)
            }
            fetchDictionary.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    static var allTests : [(String, (NetworkTests) -> () throws -> Void)] {
        return [
            ("testFetchDictionary", testFetchDictionary),
        ]
    }
    
}
