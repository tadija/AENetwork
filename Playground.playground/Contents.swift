import PlaygroundSupport
import AENetwork

PlaygroundPage.current.needsIndefiniteExecution = true

/// - Note: Convenient creation of request
let request = URLRequest.get(url: "https://httpbin.org/get")

/// - Note: Using custom `Network` instance
let network = Network()

/// - Note: Integrated Reachability
let isOnline = network.reachability.isConnectedToNetwork

/// - Note: Fetching with throwable completion closure
network.sendRequest(request) { (result) in
    do {
        let dictionary = try result().toDictionary()
        print(dictionary)
    } catch {
        print(error)
    }
}

/// - Note: Convenient fetching directly from request (using `Network.shared` by default)
request.send { (result) in
    print(String(describing: try? result().dictionary))
}
