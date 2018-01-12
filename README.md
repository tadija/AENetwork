# AENetwork

**Swift package for simple and lightweight networking**

> I made this for personal use, feel free to use it or contribute if you like.

## Usage

### TL;DR

```swift
import AENetwork

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
