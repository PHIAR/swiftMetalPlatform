import Foundation
import Metal
import XCTest

internal final class swiftMetalPlatformTests: XCTestCase {
    func testMetalCreateSystemDefaultDevice() {
        let _device = MTLCreateSystemDefaultDevice()

        XCTAssertNotNil(_device)

        let device = _device!

        print()
        print("Found device")
        print("    \(device)")
        print()
        print("Device Information")
        print("    Name:       \(device.name)")
        print("    Headless:   \(device.isHeadless)")
        print("    Low power:  \(device.isLowPower)")
        print("    Removable:  \(device.isRemovable)")
        print("    RegistryID: \(String(format: "%x", device.registryID))")
        print()
        print("Device Limits")
        print("    Maximum buffer length: \(device.maxBufferLength)")
        print("    Maximum threads per threadgroup: \(device.maxThreadsPerThreadgroup)")
        print()

        print("Compiling default shader library in bundle")

        let source = """
        __kernel void
        clMemcpy(__global uchar *dst,
                 __global uchar const *src,
                 __read_only image2d_t image)
        {
            int index = get_global_id(0);

            dst[index] = src[index];
        }
        """
        let compileOptions = MTLCompileOptions()

        compileOptions.languageVersion = .clVersion1_0

        var _library: MTLLibrary? = nil

        do {
            _library = try device.makeLibrary(source: source,
                                              options: compileOptions)
        } catch MTLLibraryError.buildFailure(let log) {
            print()
            print("Build failure:")
            print(log)
        } catch {
            preconditionFailure()
        }

        XCTAssertNotNil(_library)

        let library = _library!
        let _function = library.makeFunction(name: "clMemcpy")

        XCTAssertNotNil(_function)

        let function = _function!

        print()

        print("Creating a compute pipeline for the compute task")

        let computePipelineState = try! device.makeComputePipelineState(function: function)

        print("    Maximum total threads per threadgroup: \(computePipelineState.maxTotalThreadsPerThreadgroup)")
        print("    Static threadgroup memory length: \(computePipelineState.staticThreadgroupMemoryLength)")
        print("    Thread execution width: \(computePipelineState.threadExecutionWidth)")
        print()

        print("Allocating buffers for compute task")

        let bufferLength = 64
        let _buffer = device.makeBuffer(length: bufferLength,
                                        options: .storageModeShared)

        XCTAssertNotNil(_buffer)

        let buffer = _buffer!

        buffer.label = "buffer0"

        XCTAssertEqual(buffer.length, bufferLength)
        XCTAssertEqual(buffer.storageMode, .shared)

        print("    \(buffer)")
        print()

        let sourceBuffer = device.makeBuffer(length: bufferLength,
                                             options: .storageModeShared)
        XCTAssertNotNil(sourceBuffer)

        let _sourceBuffer = sourceBuffer!

        _sourceBuffer.label = "buffer1"

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                  width: 512,
                                                                  height: 512,
                                                                  mipmapped: false)

        print("Allocating texture for compute task")

        let _texture = device.makeTexture(descriptor: descriptor)

        XCTAssertNotNil(_texture)

        let texture = _texture!

        texture.label = "texture0"

        print("    \(texture)")
        print()

        print("Building a command queue for compute task")

        let _commandQueue = device.makeCommandQueue()

        XCTAssertNotNil(_commandQueue)

        let commandQueue = _commandQueue!

        commandQueue.label = "Metal Command Queue"

        print("    \(commandQueue)")
        print()

        let _commandBuffer = commandQueue.makeCommandBuffer()

        XCTAssertNotNil(_commandBuffer)

        let commandBuffer = _commandBuffer!

        print("Creating a blit command encoder")
        print()

        let _blitCommandEncoder = commandBuffer.makeBlitCommandEncoder()

        XCTAssertNotNil(_blitCommandEncoder)

        let blitCommandEncoder = _blitCommandEncoder!

        blitCommandEncoder.fill(buffer: _sourceBuffer,
                                range: 0..<_sourceBuffer.length,
                                value: 0xff)
        blitCommandEncoder.endEncoding()

        print("Creating a compute command encoder")
        print()

        let _computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()

        XCTAssertNotNil(_computeCommandEncoder)

        let computeCommandEncoder = _computeCommandEncoder!

        computeCommandEncoder.setComputePipelineState(computePipelineState)

        let threadsPerGrid = MTLSize(width: bufferLength,
                                     height: 1,
                                     depth: 1)
        let threadsPerThreadgroup = MTLSize(width: bufferLength,
                                            height: 1,
                                            depth: 1)

        print("Issuing kernel with threadsPerGrid: \(threadsPerGrid) and threadsPerThreadgroup: \(threadsPerThreadgroup)")
        print()

        computeCommandEncoder.setBuffer(buffer,
                                        offset: 0,
                                        index: 0)
        computeCommandEncoder.setBuffer(_sourceBuffer,
                                        offset: 0,
                                        index: 1)
        computeCommandEncoder.setTexture(texture,
                                         index: 0)
        computeCommandEncoder.dispatchThreads(threadsPerGrid,
                                              threadsPerThreadgroup: threadsPerThreadgroup)
        computeCommandEncoder.endEncoding()

        let expectation = XCTestExpectation(description: "Command completion expectation")

        commandBuffer.addCompletedHandler { _ in
            expectation.fulfill()
            print()
            print("Task completed")
            print()
        }

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        self.wait(for: [expectation],
                  timeout: 10.0)

        XCTAssertEqual(_sourceBuffer.contents().assumingMemoryBound(to: UInt8.self).pointee, 0xff)
        XCTAssertEqual(buffer.contents().assumingMemoryBound(to: UInt8.self).pointee, 0xff)
    }
}
