import swiftVulkan
import vulkan
import Foundation
import MetalProtocols

internal final class VkMetalBuffer: VkMetalResource,
                                    Buffer {
    private let _length: Int
    private let _contents: UnsafeMutableRawPointer
    private let deviceMemory: VulkanDeviceMemory

    internal let buffer: VulkanBuffer

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
        let _device = device.getDevice()
        let buffer = _device.createBuffer(size: length,
                                          usage: VK_BUFFER_USAGE_STORAGE_BUFFER_BIT.rawValue |
                                                 VK_BUFFER_USAGE_TRANSFER_DST_BIT.rawValue |
                                                 VK_BUFFER_USAGE_TRANSFER_SRC_BIT.rawValue,
                                          queueFamilies: [ device.sharedMemoryTypeIndex ])
        let bufferMemoryRequirements = buffer.getBufferMemoryRequirements()
        let deviceMemory = _device.allocateMemory(size: Int(bufferMemoryRequirements.size),
                                                  memoryTypeIndex: 0)

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

    internal func getBuffer() -> VulkanBuffer {
        return self.buffer
    }

    public func contents() -> UnsafeMutableRawPointer {
        self._contents
    }
}
