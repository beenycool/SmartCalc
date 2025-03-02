// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SmartCalc",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SmartCalc",
            targets: ["SmartCalc"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.13.0"),
        .package(url: "https://github.com/attaswift/BigInt", from: "5.3.0"),
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.9.8")
    ],
    targets: [
        .target(
            name: "SmartCalc",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Numerics", package: "swift-numerics"),
                .product(name: "Parsing", package: "swift-parsing"),
                .product(name: "BigInt", package: "BigInt")
            ]
        ),
        .testTarget(
            name: "SmartCalcTests",
            dependencies: [
                "SmartCalc",
                .product(name: "ViewInspector", package: "ViewInspector")
            ]
        )
    ]
)