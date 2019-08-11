/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2019
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class APIClientTests: XCTestCase {
    
    static var allTests : [(String, (APIClientTests) -> () throws -> Void)] {
        return [
            ("testAPIRequest", testAPIRequest),
            ("testAPIResponse", testAPIResponse)
        ]
    }
    
    // MARK: Tests
    
    func testAPIClient() {
        struct Get: APIRequest {
            var method: URLRequest.Method {
                return .get
            }
            var path: String {
                return "get"
            }
        }
        struct Post: APIRequest {
            var method: URLRequest.Method {
                return .post
            }
            var path: String {
                return "post"
            }
        }
        struct Put: APIRequest {
            var method: URLRequest.Method {
                return .put
            }
            var path: String {
                return "put"
            }
        }
        struct Patch: APIRequest {
            var method: URLRequest.Method {
                return .patch
            }
            var path: String {
                return "patch"
            }
        }
        struct Delete: APIRequest {
            var method: URLRequest.Method {
                return .delete
            }
            var path: String {
                return "delete"
            }
        }
        
        struct Backend: APIClient {
            let baseURL: URL = "https://httpbin.org"
            func send(_ apiRequest: APIRequest, completion: @escaping APIResponseCallback) {}
        }
        
        let backend = Backend()
        let getRequest = backend.urlRequest(for: Get())
        let postRequest = backend.urlRequest(for: Post())
        let putRequest = backend.urlRequest(for: Put())
        let patchRequest = backend.urlRequest(for: Patch())
        let deleteRequest = backend.urlRequest(for: Delete())
        
        XCTAssertEqual(getRequest, URLRequest.get(url: "https://httpbin.org/get"))
        XCTAssertEqual(postRequest, URLRequest.post(url: "https://httpbin.org/post"))
        XCTAssertEqual(putRequest, URLRequest.put(url: "https://httpbin.org/put"))
        XCTAssertEqual(patchRequest, URLRequest.patch(url: "https://httpbin.org/patch"))
        XCTAssertEqual(deleteRequest, URLRequest.delete(url: "https://httpbin.org/delete"))
    }
    
    func testAPIRequest() {
        struct Foo: APIRequest {
            var method: URLRequest.Method {
                return .get
            }
            var path: String {
                return "foo"
            }
        }
        let foo = Foo()
        XCTAssertNil(foo.headers)
        XCTAssertNil(foo.parameters)
        XCTAssertNil(foo.cachePolicy)
        
        struct Bar: APIRequest {
            var method: URLRequest.Method {
                return .post
            }
            var path: String {
                return "bar"
            }
            var headers: [String : String]? {
                return ["Header" : "Value"]
            }
            var parameters: [String : Any]? {
                return ["Parameter" : "Value"]
            }
            var cachePolicy: URLRequest.CachePolicy? {
                return .reloadIgnoringCacheData
            }
        }
        let bar = Bar()
        XCTAssertEqual(bar.method, .post)
        XCTAssertEqual(bar.path, "bar")
        XCTAssertEqual(bar.headers!, ["Header" : "Value"])
        XCTAssertEqual(bar.parameters?["Parameter"] as? String, "Value")
        XCTAssertEqual(bar.cachePolicy, .reloadIgnoringCacheData)
    }
    
    func testAPIResponse() {
        struct Response: APIResponse {
            var request: URLRequest
            var response: HTTPURLResponse
            var data: Data
            
            init() {
                let url: URL = "https://httpbin.org/get"
                request = URLRequest(url: url)
                response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["foo" : "bar"])!
                data = try! Data(jsonWith: ["foo" : "bar"])
            }
        }
        
        let response = Response()
        
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.headers["foo"] as? String, "bar")
        XCTAssertNoThrow(try response.toDictionary())
        XCTAssertEqual(try response.toDictionary()["foo"] as? String, "bar")
        XCTAssertThrowsError(try response.toArray())
        
        let shortDescription = """
        Request: \(response.request.shortDescription) | Response: \(response.response.shortDescription)
        """
        XCTAssertEqual(response.shortDescription, shortDescription)

        let fullDescription = "\(response.request.fullDescription)\n\(response.response.fullDescription)"
        XCTAssertEqual(response.fullDescription, fullDescription)
    }
    
}
