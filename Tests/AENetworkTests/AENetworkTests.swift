import XCTest
@testable import AENetwork

class AENetworkTests: XCTestCase {
    
    func testFetchDictionary() {
        let fetchDictionary = expectation(description: "Fetch Dictionary")
        
        guard let url = URL(string: "https://httpbin.org/get")
        else { return }
        
        let request = URLRequest(url: url)
        AENetwork.shared.fetchDictionary(with: request) { (closure) in
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
    
    func testParameters() {
        guard let url = URL(string: "https://httpbin.org")
        else { return }
        
        let parameters = [
            "foo" : "bar",
            "bar" : "foo"
        ]
        let urlWithParameters = url.addingParameters(parameters)
        
        let bar = urlWithParameters?.parameterValue(forKey: "foo")
        let foo = urlWithParameters?.parameterValue(forKey: "bar")
        
        if bar == "bar" && foo == "foo" {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
    }

    static var allTests : [(String, (AENetworkTests) -> () throws -> Void)] {
        return [
            ("testFetchDictionary", testFetchDictionary),
            ("testParameters", testParameters)
        ]
    }
    
}
