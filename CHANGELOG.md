# Changelog

## Version 0.6.1

- Added detailed error description
- Added short description for URLRequest and HTTPURLResponse
- Other improvements and refactoring

## Version 0.6.0

- Fixed logic for preventing of sending duplicated requests
- Implemented logic for performing all work in background queue
- Refactored BackendAPI logic into Backend
- Other improvements and refactoring

## Version 0.5.0

- Removed failable completion alternatives
- Removed custom caching logic
- Added URLRequest.CachePolicy to BackendRequest
- Prevented sending duplicated requests
- Other improvements and refactoring

## Version 0.4.0

- Added failable completion alternatives to Network.Completion
- Added optional alternatives of serialized data in Fetcher.Result
- Added HTTPURLResponse+Helper
- Added more unit tests
- Other improvements and refactoring

## Version 0.3.5

- Possibility to provide custom completion queue when sending network request
- Minor other fixes

## Version 0.3.4

- Added Reachability

## Version 0.3.3
- Added logic to intercept any request / response with NetworkDelegate
- Improved Backend logic (added BackendAPI protocol)
- Other improvements and refactoring

## Version 0.3.2
- Created initial version of Backend and BackendRequest protocols
- Improvements and refactoring

## Version 0.3.1
- Improvements of delegates logic
- Minor fixes and refactoring
- Added sample Playground

## Version 0.3.0
- Major refactoring of Caching logic
- Major refactoring or request / response logic
- Other improvements and refactoring

## Version 0.2.9
- Refactored Parser into Data+Serialization extension
- Improvements and bug fixes

## Version 0.2.8
- Added more helpers to URLRequest extension
- Added Failable alternatives to Completion
- Improvements and refactoring
- Added more unit tests

## Version 0.2.7
- Added initial NetworkDelegate
- Added URL+ExpressibleByStringLiteral helper
- Improvements and refactoring

## Version 0.2.6

- Added initial facade API to Network
- Added convenience API to URLRequest
- Improvements and refactoring

## Version 0.2.5

- Downloader improvements

## Version 0.2.4

- Improvements and refactoring
- Added more unit tests

## Version 0.2.3

- Improvements and refactoring
- Added more unit tests

## Version 0.2.2

- Improvements and refactoring
- Added more unit tests

## Version 0.2.1

- Renamed module (Network -> AENetwork)
- Major refactoring

## Version 0.2.0

- Migrated to Swift 4 with Xcode 9.1

## Version 0.1.9

- Added support for Carthage

## Version 0.1.8

- Moved all code into single source file
- Minor refactoring

## Version 0.1.7

- Added badRequest case in AENetworkError

## Version 0.1.6

- Minor refactoring

## Version 0.1.5

- Minor improvements and refactoring

## Version 0.1.4

- Added URL extension with convenience methods for using query parameters

## Version 0.1.3

- Minor improvements and refactoring

## Version 0.1.2

- Added public initializer
- Renamed typealiases and minor refactoring

## Version 0.1.1

- Minor improvements and refactoring
- Added initial unit test

## Version 0.1.0

- Initial version
