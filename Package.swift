// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "Networking",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    .library(name: "Networking", targets: ["Networking"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire", from: "5.10.2"),
  ],
  targets: [
    .target(name: "Networking", dependencies: ["Alamofire"]),
  ]
)
