// swift-tools-version:5.2

import PackageDescription

var products: [Product] = []
var targets: [Target] = []

let platforms: [SupportedPlatform] = [
    .iOS("13.2"),
    .macOS("10.15"),
    .tvOS("13.2")
]

// MARK - Metal

let spirvCrossTarget = Target.systemLibrary(name: "SPIRVCross")
let spirvReflectTarget = Target.target(name: "SPIRVReflect")
let metalProtocolsTarget = Target.target(name: "MetalProtocols",
                                         dependencies: [])
let metalTarget = Target.target(name: "Metal",
                                dependencies: [
    "swiftVulkan",
    "MetalProtocols",
    "SPIRVCross",
    "SPIRVReflect",
],
                                path: "Sources/MetalVulkanBackend")
let metalTestTarget = Target.testTarget(name: "swiftMetalPlatformTests",
                                        dependencies: [
    "SPIRVCross",
    "Metal",
])

targets.append(spirvCrossTarget)
targets.append(spirvReflectTarget)
targets.append(metalProtocolsTarget)
targets.append(metalTarget)
targets.append(metalTestTarget)

// MARK - Package configuration

products.append(.library(name: "Metal",
                         type: .dynamic,
                         targets: [
    "Metal",
]))

let package = Package(name: "swiftMetalPlatform",
                      platforms: platforms,
                      products: products,
                      dependencies: [
    .package(url: "https://github.com/PHIAR/swiftVulkan.git",
             .branch("master")),
],
                      targets: targets)
