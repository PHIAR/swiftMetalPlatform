import swiftVulkan
import vulkan
import Foundation
import MetalProtocols

internal final class VkMetalBuffer: VkMetalResource,
                                    Buffer {
    private let _length: Int
    private let _contents: UnsafeMutableRawPointer
    private let buffer: VulkanBuffer
    private let deviceMemory: VulkanDeviceMemory

    public override var allocatedSize: Int {
        return self.length
    }

    public override var description: String {
        return super.description + " length: \(self.length) contents: \(self.contents())"
    }

    public var length: Int {
        return self._length
    }

    internal init(device: VkMetalDevice,
                  length: Int) {
        let deviceMemory = device.device.allocateMemory(size: length,
                                                        memoryTypeIndex: 0)
        let buffer = device.device.createBuffer(size: length,
                                                usage: VK_BUFFER_USAGE_STORAGE_BUFFER_BIT.rawValue,
                                                queueFamilies: [ 0 ])

        buffer.bindBufferMemory(deviceMemory: deviceMemory,
                                offset: 0)

        let contents = deviceMemory.map()

        self._length = length
        self._contents = contents
        self.deviceMemory = deviceMemory
        self.buffer = buffer
        super.init(device: device)
    }

    deinit {
        self.deviceMemory.unmap()
    }

    public func contents() -> UnsafeMutableRawPointer {
        self._contents
    }
}
