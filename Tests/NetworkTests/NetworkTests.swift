import XCTest
@testable import Network

class NetworkTests: XCTestCase {
    
    func testFetchDictionary() {
        let fetchDictionary = expectation(description: "Fetch Dictionary")
        
        guard let url = URL(string: "https://httpbin.org/get")
        else { return }
        
        let request = URLRequest(url: url)
        Network.shared.fetchDictionary(with: request) { (closure) in
            do {
                let dictionary = try closure()
                debugPrint(dictionary)
                XCTAssert(true)
            } catch {
                debugPrint(error)
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
