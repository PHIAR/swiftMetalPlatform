import Foundation
import Metal
import SPIRVCross
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

        let spirv: [UInt32] = [
            0x07230203,
            0x00010000,
            0x00150000,
            0x00000021,
            0x00000000,
            0x00020011,
            0x00000001,
            0x00020011,
            0x00000027,
            0x000B000A,
            0x5F565053,
            0x5F52484B,
            0x726F7473,
            0x5F656761,
            0x66667562,
            0x735F7265,
            0x61726F74,
            0x635F6567,
            0x7373616C,
            0x00000000,
            0x0003000E,
            0x00000000,
            0x00000001,
            0x0007000F,
            0x00000005,
            0x0000001A,
            0x654D6C63,
            0x7970636D,
            0x00000000,
            0x00000011,
            0x00030003,
            0x00000003,
            0x00000078,
            0x00040047,
            0x00000003,
            0x00000006,
            0x00000001,
            0x00050048,
            0x00000004,
            0x00000000,
            0x00000023,
            0x00000000,
            0x00030047,
            0x00000004,
            0x00000002,
            0x00040047,
            0x00000011,
            0x0000000B,
            0x0000001C,
            0x00040047,
            0x00000015,
            0x0000000B,
            0x00000019,
            0x00040047,
            0x00000017,
            0x00000022,
            0x00000000,
            0x00040047,
            0x00000017,
            0x00000021,
            0x00000000,
            0x00040047,
            0x00000018,
            0x00000022,
            0x00000000,
            0x00040047,
            0x00000018,
            0x00000021,
            0x00000001,
            0x00040047,
            0x00000019,
            0x00000022,
            0x00000000,
            0x00040047,
            0x00000019,
            0x00000021,
            0x00000002,
            0x00040047,
            0x00000012,
            0x00000001,
            0x00000000,
            0x00040047,
            0x00000013,
            0x00000001,
            0x00000001,
            0x00040047,
            0x00000014,
            0x00000001,
            0x00000002,
            0x00030016,
            0x00000001,
            0x00000020,
            0x00040015,
            0x00000002,
            0x00000008,
            0x00000000,
            0x0003001D,
            0x00000003,
            0x00000002,
            0x0003001E,
            0x00000004,
            0x00000003,
            0x00040020,
            0x00000005,
            0x0000000C,
            0x00000004,
            0x00090019,
            0x00000006,
            0x00000001,
            0x00000001,
            0x00000000,
            0x00000000,
            0x00000000,
            0x00000001,
            0x00000000,
            0x00040020,
            0x00000007,
            0x00000000,
            0x00000006,
            0x00020013,
            0x00000008,
            0x00030021,
            0x00000009,
            0x00000008,
            0x00040015,
            0x0000000A,
            0x00000020,
            0x00000000,
            0x00040017,
            0x0000000B,
            0x0000000A,
            0x00000003,
            0x00040020,
            0x0000000C,
            0x00000001,
            0x0000000B,
            0x00040020,
            0x0000000D,
            0x00000001,
            0x0000000A,
            0x00040020,
            0x0000000E,
            0x0000000C,
            0x00000002,
            0x00040020,
            0x0000000F,
            0x00000006,
            0x0000000B,
            0x0004002B,
            0x0000000A,
            0x00000010,
            0x00000000,
            0x0004003B,
            0x0000000C,
            0x00000011,
            0x00000001,
            0x00040032,
            0x0000000A,
            0x00000012,
            0x00000001,
            0x00040032,
            0x0000000A,
            0x00000013,
            0x00000001,
            0x00040032,
            0x0000000A,
            0x00000014,
            0x00000001,
            0x00060033,
            0x0000000B,
            0x00000015,
            0x00000012,
            0x00000013,
            0x00000014,
            0x0005003B,
            0x0000000F,
            0x00000016,
            0x00000006,
            0x00000015,
            0x0004003B,
            0x00000005,
            0x00000017,
            0x0000000C,
            0x0004003B,
            0x00000005,
            0x00000018,
            0x0000000C,
            0x0004003B,
            0x00000007,
            0x00000019,
            0x00000000,
            0x00050036,
            0x00000008,
            0x0000001A,
            0x00000000,
            0x00000009,
            0x000200F8,
            0x0000001B,
            0x00050041,
            0x0000000D,
            0x0000001C,
            0x00000011,
            0x00000010,
            0x0004003D,
            0x0000000A,
            0x0000001D,
            0x0000001C,
            0x00060041,
            0x0000000E,
            0x0000001E,
            0x00000018,
            0x00000010,
            0x0000001D,
            0x0004003D,
            0x00000002,
            0x0000001F,
            0x0000001E,
            0x00060041,
            0x0000000E,
            0x00000020,
            0x00000017,
            0x00000010,
            0x0000001D,
            0x0003003E,
            0x00000020,
            0x0000001F,
            0x000100FD,
            0x00010038,
        ]
        let compileOptions = MTLCompileOptions()

        compileOptions.languageVersion = .clVersion1_0

        let library = device.makeLibrary(spirv: spirv)
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

    func testMetalTextureClears() {
        let device = MTLCreateSystemDefaultDevice()!
        let commandQueue = device.makeCommandQueue()!
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                  width: 64,
                                                                  height: 64,
                                                                  mipmapped: false)

        descriptor.usage = [
            .renderTarget,
            .shaderRead,
            .shaderWrite,
        ]

        let texture = device.makeTexture(descriptor: descriptor)!
        let buffer = device.makeBuffer(length: descriptor.width * descriptor.height * 4,
                                       options: .storageModeShared)!
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderPassDescriptor = MTLRenderPassDescriptor()

        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1.0,
                                                                            green: 0.0,
                                                                            blue: 0.0,
                                                                            alpha: 1.0)
        let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

        renderCommandEncoder.endEncoding()

        let blitCommandEncoder = commandBuffer.makeBlitCommandEncoder()!

        blitCommandEncoder.fill(buffer: buffer,
                                range: 0..<descriptor.width * descriptor.height * 4,
                                value: 0)
        blitCommandEncoder.copy(from: texture,
                                sourceSlice: 0,
                                sourceLevel: 0,
                                sourceOrigin: MTLOrigin(),
                                sourceSize: MTLSize(width: descriptor.width,
                                                    height: descriptor.height,
                                                    depth: 1),
                                to: buffer,
                                destinationOffset: 0,
                                destinationBytesPerRow: descriptor.width * 4,
                                destinationBytesPerImage: descriptor.width * descriptor.height * 4)
        blitCommandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        let array = Array(UnsafeBufferPointer(start: buffer.contents().assumingMemoryBound(to: UInt8.self),
                                              count: descriptor.width * descriptor.height * 4))

        XCTAssertEqual(array.reduce(0) { $0 + Int($1) }, array.count / 4 * 255 * 2)
    }
}
