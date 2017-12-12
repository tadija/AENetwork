# AENetwork

**Swift package for networking**

> I made this for personal use, feel free to use it or contribute if you like.

## Usage

```swift
import AENetwork

/// - Note: Convenient creation of request
let request = URLRequest(url: "https://httpbin.org/get")

/// - Note: Fetching with throwable completion closure
let network = Network()
network.fetchDictionary(with: request) { (closure) in
    do {
        let dictionary = try closure()
        print(dictionary)
    } catch {
        print(error)
    }
}

/// - Note: Fetching directly from request (using shared instance)
request.fetchDictionary { (closure) in
    do {
        let dictionary = try closure()
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

## License
This code is released under the MIT license. See [LICENSE](LICENSE) for details.
