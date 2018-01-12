import PlaygroundSupport
import AENetwork

PlaygroundPage.current.needsIndefiniteExecution = true

/// - Note: Convenient creation of URL from String
var url: URL = "https://httpbin.org/post"

/// - Note: Easily add parameters to URL
url.addParameters(["foo" : "bar"])

/// - Note: Convenient creation of URL request
let request = URLRequest.post(url: url,
                              headers: ["X-Hello" : "X-World"],
                              parameters: ["like" : true])

/// - Note: Using custom `Network` instance
let network = Network()

/// - Note: Integrated Reachability
print("Connected to network: \(network.reachability.isConnectedToNetwork)")

/// - Note: Be notified about connection changes
network.reachability.startNotifier()
network.reachability.connectionDidChange = { r in
    print("Connection type: \(r.connection.rawValue)\n")
}
network.reachability.stopNotifier()

/// - Note: Fetching with throwable completion closure
network.sendRequest(request) { (result) in
    do {
        let dictionary = try result().toDictionary()
        print("\(dictionary)\n")
    } catch {
        print("\(error)\n")
    }
}

/// - Note: Convenient fetching directly from request (using `Network.shared` by default)
request.send { (result) in
    print("\(String(describing: try? result().dictionary))\n")
}

/// - Note: Convenient creation of entire backend layer

struct MyBackendAPI: BackendAPI {
    let baseURL = "https://httpbin.org".url
}

extension MyBackendAPI {
    struct Test: BackendRequest {
        var method: URLRequest.Method {
            return .put
        }
        var endpoint: String {
            return "anything"
        }
    }
}

class MyBackend: Backend {
    typealias API = MyBackendAPI
    let api: BackendAPI = MyBackendAPI()
    let network = Network()
}

extension MyBackend {
    func sendTestRequest() {
        let request = API.Test()
        sendRequest(request, completionQueue: .main) { (result) in
            print("\(String(describing: try? result().dictionary))\n")
        }
    }
}

let backend = MyBackend()
backend.sendTestRequest()
