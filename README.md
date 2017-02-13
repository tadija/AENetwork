# Network

**Swift package for networking**

> I made this for personal use, feel free to use it or contribute if you like.

## Include

- [Swift Package Manager](https://swift.org/package-manager/):

```swift
.Package(url: "https://github.com/tadija/network.git", majorVersion: 0)
```

## Use

```swift
import Network

let url = URL(string: "https://httpbin.org/get")!
let request = URLRequest(url: url)
    
Network.shared.fetchDictionary(with: request) { (closure) in
    do {
        let dictionary = try closure()
        print(dictionary)
    } catch {
        print(error)
    }
}
```

> For more examples check out [Sources](Sources) and [Tests](Tests).

## License
This code is released under the MIT license. See [LICENSE](LICENSE) for details.
