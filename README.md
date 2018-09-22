[![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat)](https://swift.org)
[![Platforms iOS | watchOS | tvOS | macOS](https://img.shields.io/badge/Platforms-iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20macOS-lightgray.svg?style=flat)](http://www.apple.com)
[![CocoaPods](https://img.shields.io/cocoapods/v/AENetwork.svg?style=flat)](https://cocoapods.org/pods/AENetwork)
[![Carthage](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://github.com/tadija/AENetwork/blob/master/LICENSE)

# AENetwork

**Swift minion for simple and lightweight networking**

> I made this for personal use, but feel free to use it or contribute.
> For more examples check out [Sources](Sources) and [Tests](Tests).

## Usage

```swift
import AENetwork

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

/// - Note: `APIClient` will by default use shared `Network` instance for sending `APIRequest`,
/// but a custom `APIClient` implementation can do it via specific `Network` instance,
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
```

## Installation

- [Swift Package Manager](https://swift.org/package-manager/):

	```swift
	.Package(url: "https://github.com/tadija/AENetwork.git", majorVersion: 0)
	```

- [Carthage](https://github.com/Carthage/Carthage):

	```ogdl
	github "tadija/AENetwork"
	```

- [CocoaPods](http://cocoapods.org/):

	```ruby
	pod 'AENetwork'
	```

## License
This code is released under the MIT license. See [LICENSE](LICENSE) for details.
