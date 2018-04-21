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

/// - Note: Send request with `Fetcher` and use `ResponseResult` in completion
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
    let baseURL: URL = "https://httpbin.org"
}

/// - Note: `APIClient` will by default use a shared instance of `Network` for sending the `APIRequest`,
/// but a custom implementation of the `APIClient` protocol can do it via specific `Network` instance,
/// or even via any other way to resolve `APIRequest` and return `APIResponse` in the completion.

/// - Note: Type safe and scalable architecture of API requests
extension Backend {
    struct API {}
}
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
let apiRequest = Backend.API.Anything()
backend.send(apiRequest) { (result) in
    switch result {
    case .success(let response):
        print("Response: \(response.dictionary?.description ?? "")\n")
    case .failure(let error):
        print(error)
    }
}
