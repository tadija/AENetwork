import PlaygroundSupport
import AENetwork

PlaygroundPage.current.needsIndefiniteExecution = true

/// - Note: Convenient creation of request
let request = URLRequest.get(url: "https://httpbin.org/get")

/// - Note: Fetching directly from request (using `Network.shared` by default)
request.send { (result) in
    let dictionary = try? result().toDictionary()
    print(String(describing: dictionary))
}

/// - Note: Fetching with throwable completion closure (using custom `Network` instance)
let network = Network()
network.sendRequest(request) { (result) in
    do {
        let dictionary = try result().toDictionary()
        print(dictionary)
    } catch {
        print(error)
    }
}
