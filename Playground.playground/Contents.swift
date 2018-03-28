import PlaygroundSupport
import AENetwork

PlaygroundPage.current.needsIndefiniteExecution = true

/// - Note: Make `URL` with just a `String`
let anything: URL = "https://httpbin.org/anything"

/// - Note: Easily add parameters to `URL`
let url = anything.addingParameters(["foo" : "bar"])!

/// - Note: Factory methods on `URLRequest`
let request = URLRequest.post(url: url, headers: ["hello" : "world"], parameters: ["easy" : true])

/// - Note: Convenient sending of request
request.send { (result) in
    if let response = result.value {
        print("Status Code: \(response.statusCode)\n")
    }
}

/// - Note: Integrated `Reachability`
print("Connected to network: \(Network.isOnline)")

/// - Note: Create custom `Network` instance when needed
let network = Network()

/// - Note: Monitor reachability state changes
network.reachability.startMonitoring()
network.reachability.stateDidChange = { state in
    print("Reachability state: \(state.rawValue)\n")
}
network.reachability.stopMonitoring()

/// - Note: Send request with `Fetcher` and use `Result<Fetcher.Response>` in completion
network.fetcher.send(request) { (result) in
    do {
        let response = try result.throwValue()
        print("Headers: \(response.headers as? [String : Any])\n")
    } catch {
        print(error)
    }
}

/// - Note: Simple creation of the entire backend layer
final class Backend: APIClient {
    struct API {}
    let baseURL: URL = "https://httpbin.org"

    func send(_ apiRequest: APIRequest, completion: @escaping (Result<APIResponse>) -> Void) {
        let request = urlRequest(for: apiRequest)
        request.send { (result) in
            completion(Fetcher.apiResponseResult(from: result))
        }
    }
}

/// - Note: Type safe and scalable architecture of API requests
extension Backend.API {
    struct Anything: APIRequest {
        var method: URLRequest.Method { return .get }
        var path: String { return "anything" }
        var headers: [String : String]? { return ["X-Hello" : "X-World"] }
        var parameters: [String : Any]? { return ["easy" : true] }
    }
}

/// - Note: `Backend` example in action
let backend = Backend()
backend.send(Backend.API.Anything()) { (result) in
    switch result {
    case .success(let response):
        print("Response: \(response.dictionary?.description ?? "")\n")
    case .failure(let error):
        print(error)
    }
}
