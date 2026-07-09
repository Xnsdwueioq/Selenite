// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "FocusCore",
  platforms: [.iOS(.v18), .watchOS(.v11), .macOS(.v15)],
  products: [
    .library(
      name: "FocusCore",
      targets: ["FocusCore"]
    ),
  ],
  targets: [
    .target(
      name: "FocusCore",
      swiftSettings: [
        .enableUpcomingFeature("ApproachableConcurrency"),
      ],
    ),
    .testTarget(
      name: "FocusCoreTests",
      dependencies: ["FocusCore"],
      swiftSettings: [
        .enableUpcomingFeature("ApproachableConcurrency"),
      ],
    ),
  ],
  swiftLanguageModes: [.v6]
)
