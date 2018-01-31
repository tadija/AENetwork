# AENetwork

**Swift package for simple and lightweight networking**

> I made this for personal use, feel free to use it or contribute if you like.

## Usage

### TL;DR

```swift
import AENetwork

/// - Note: Convenient creation of URL from String
var url: URL = "https://httpbin.org/post"

/// - Note: Easily adding parameters to URL
url.addParameters(["foo" : "bar"])

/// - Note: Convenient creation of URL request
let request = URLRequest.post(url: url,
                              headers: ["X-Hello" : "X-World"],
                              parameters: ["like" : true])

/// - Note: Creating custom `Network` instance
let network = Network()

/// - Note: Integrated Reachability
print("Connected to network: \(network.reachability.isConnectedToNetwork)")

/// - Note: Listening for connection changes
network.reachability.startNotifier()
network.reachability.connectionDidChange = { r in
    print("Connection type: \(r.connection.rawValue)\n")
}
network.reachability.stopNotifier()

/// - Note: Fetching with throwable completion closure
network.fetchRequest(request) { (result) in
    do {
        let dictionary = try result().toDictionary()
        print("\(dictionary)\n")
    } catch {
        print("\(error)\n")
    }
}

/// - Note: Convenient fetching directly from request (using `Network.shared` by default)
request.fetch { (result) in
    print("\(String(describing: try? result().dictionary))\n")
}

/// - Note: Convenient creation of entire backend layer

class MyBackend: Backend {
    struct API {}
    let baseURL = "https://httpbin.org".url
}

extension MyBackend {
    func sendTestRequest() {
        let request = API.Test()
        sendRequest(request) { (result) in
            print("\(String(describing: try? result().dictionary))\n")
        }
    }
}

extension MyBackend.API {
    struct Test: BackendRequest {
        var method: URLRequest.Method {
            return .put
        }
        var endpoint: String {
            return "anything"
        }
    }
}

let backend = MyBackend()
backend.sendTestRequest()

```

> For more examples check out [Sources](Sources) and [Tests](Tests).

## Installation

- [Swift Package Manager](https://swift.org/package-manager/):

```swift
.Package(url: "https://github.com/tadija/AENetwork.git", majorVersion: 0)
```

- [Carthage](https://github.com/Carthage/Carthage):

```ogdl
github "tadija/AENetwork"
```

## License
This code is released under the MIT license. See [LICENSE](LICENSE) for details.
