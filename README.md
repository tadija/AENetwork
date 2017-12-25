# AENetwork

**Swift package for simple and lightweight networking**

> I made this for personal use, feel free to use it or contribute if you like.

## Usage

### TL;DR

```swift
import AENetwork

/// - Note: Convenient creation of request
let request = URLRequest.get(url: "https://httpbin.org/get")

/// - Note: Fetching directly from request (using `Network.shared` by default)
request.perform { (result) in
    let dictionary = try? result().dictionary()
    print(String(describing: dictionary))
}

/// - Note: Fetching with throwable completion closure (using custom `Network` instance)
let network = Network()
network.performRequest(request) { (result) in
    do {
        let dictionary = try result().dictionary()
        print(dictionary)
    } catch {
        print(error)
    }
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
