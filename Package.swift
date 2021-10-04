// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "NetworkKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]
        )
    ],
    dependencies: [
        .package(
            name: "Alamofire",
            url: "https://github.com/Alamofire/Alamofire.git",
            .upToNextMajor(from: "5.4.3")
        )
    ],
    targets: [
        .target(
            name: "NetworkKit",
            dependencies: ["Alamofire"],
            path: "Sources"
        )
    ]
)
