// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "ReSwiftMonitor",
//    platforms: [.iOS("13.0")],
    products: [
        .library(name: "ReSwiftMonitor", targets: ["ReSwiftMonitor"])
    ], dependencies: [
        .package(url: "https://github.com/ReSwift/ReSwift.git", from: "6.1.0"),
        .package(url: "https://github.com/alibaba/HandyJSON.git", from: "5.0.2"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "3.1.1"),
    ],
    targets: [
        .target(
            name: "ReSwiftMonitor",
            dependencies: ["ReSwift", "HandyJSON", "Starscream"],
            path: "Sources"
        )
    ]
)
