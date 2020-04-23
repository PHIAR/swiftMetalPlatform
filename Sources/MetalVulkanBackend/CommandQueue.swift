import swiftVulkan
import Dispatch
import MetalProtocols

internal final class VkMetalCommandQueue: VkMetalObject,
                                          CommandQueue {
    private static let maxCommandBufferCount = 16

    private let deviceQueue: VulkanQueue
    private let commandPool: VulkanCommandPool
    private var commandBuffers: [VkMetalCommandBuffer]!
    private var currentIndex = 0

    internal let executionQueue = DispatchQueue(label: "VkMetalCommandQueue.executionQueue")

    public override var description: String {
        return super.description + " commandQueue:"
    }

    internal init(device: VkMetalDevice,
                  deviceQueue: VulkanQueue,
                  commandPool: VulkanCommandPool,
                  maxCommandBufferCount: Int) {
        var commandBuffers: [VulkanCommandBuffer] = []
        let _maxCommandBufferCount = (maxCommandBufferCount == 0) ? VkMetalCommandQueue.maxCommandBufferCount :
                                                                    maxCommandBufferCount

        self.deviceQueue = deviceQueue
        self.commandPool = commandPool
        super.init(device: device)

        self.commandBuffers = commandPool.allocateCommandBuffers(count: _maxCommandBufferCount).map {
            return VkMetalCommandBuffer(commandQueue: self,
                                        commandBuffer: $0)
        }
    }

    deinit {
    }

    public func makeCommandBuffer() -> CommandBuffer? {
        if self.currentIndex >= self.commandBuffers.count {
            self.currentIndex = 0
        }

        let commandBuffer = self.commandBuffers[self.currentIndex]

        self.currentIndex += 1
        return commandBuffer
    }

    public func makeCommandBufferWithUnretainedReferences() -> CommandBuffer? {
        return self.makeCommandBuffer()
    }
}
