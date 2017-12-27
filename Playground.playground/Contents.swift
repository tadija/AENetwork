import PlaygroundSupport
import AENetwork

PlaygroundPage.current.needsIndefiniteExecution = true

/// - Note: Convenient creation of request
let request = URLRequest.get(url: "https://httpbin.org/get")

/// - Note: Fetching directly from request (using `Network.shared` by default)
request.send { (result) in
    let dictionary = try? result().dictionary()
    print(String(describing: dictionary))
}

/// - Note: Fetching with throwable completion closure (using custom `Network` instance)
let network = Network()
network.sendRequest(request) { (result) in
    do {
        let dictionary = try result().dictionary()
        print(dictionary)
    } catch {
        print(error)
    }
}

class Test: NetworkDelegate {
    let n = Network()

    init() {
        n.delegate = self
    }

//    func tmp1(_ r: () throws -> Fetcher.Result, c: (() throws -> Fetcher.Result) -> Void) {
//        do {
//            let res = try r()
//            print(res)
//            c {
//                return res
//            }
//        } catch {
//            print(error)
//            c {
//                throw error
//            }
//        }
//    }
}

//let test = Test()
//test.n.sendRequest(request) { (res) in
//    do {
//        let r = try res()
//        print(r)
//    } catch {
//        print(error)
//    }
//}

//let test = Test()
//Network.shared.delegate = test
