# swiftMetalPlatform

A Metal API implementation in Swift on top of the Vulkan API.

Note this is a proof of concept implementation and is not complete.

## Building and Verification

swiftMetalPlatform requires SPIRV-Cross in order to build descriptor sets from SPIRV shaders.
SPIRV-Cross can be located at https://github.com/KhronosGroup/SPIRV-Cross.

swiftMetalPlatform uses the Swift Package Manager (swiftpm) for building.

To build:
```
swift build
```

To test:
```
swift test
```

