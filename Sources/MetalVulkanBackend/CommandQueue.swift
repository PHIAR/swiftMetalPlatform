import vulkan
import swiftVulkan
import Dispatch
import MetalProtocols

internal final class VkMetalCommandQueue: VkMetalObject,
                                          CommandQueue {
    private static let maxCommandBufferCount = 16

    private let deviceQueue: VulkanQueue
    private let commandPool: VulkanCommandPool
    private var commandBuffers: [Int: VkMetalCommandBuffer] = [:]
    private let descriptorPool: VulkanDescriptorPool

    internal let executionQueue = DispatchQueue(label: "VkMetalCommandQueue.executionQueue")

    public override var description: String {
        return """
        CommandQueue
        """
    }

    internal init(device: VkMetalDevice,
                  deviceQueue: VulkanQueue,
                  commandPool: VulkanCommandPool,
                  maxCommandBufferCount: Int) {
        let _maxCommandBufferCount = (maxCommandBufferCount == 0) ? VkMetalCommandQueue.maxCommandBufferCount :
                                                                    maxCommandBufferCount
        let maxDescriptorSets = 1
        let poolSizes = [
            VkDescriptorPoolSize(type: VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,
                                 descriptorCount: 128),
            VkDescriptorPoolSize(type: VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                 descriptorCount: 128),
            VkDescriptorPoolSize(type: VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                 descriptorCount: 128),
        ]

        let descriptorPool = device.device.createDescriptorPool(flags: VK_DESCRIPTOR_POOL_CREATE_UPDATE_AFTER_BIND_BIT.rawValue,
                                                                maxSets: maxDescriptorSets,
                                                                poolSizes: poolSizes)

        self.deviceQueue = deviceQueue
        self.commandPool = commandPool
        self.descriptorPool = descriptorPool
        super.init(device: device)

        var commandBuffers: [Int: VkMetalCommandBuffer] = [:]
        let _commandBuffers = commandPool.allocateCommandBuffers(count: _maxCommandBufferCount)

        for index in 0..<_maxCommandBufferCount {
            commandBuffers[index] = VkMetalCommandBuffer(commandQueue: self,
                                                         commandBuffer: _commandBuffers[index],
                                                         index: index)
        }

        self.commandBuffers = commandBuffers
    }

    deinit {
    }

    internal func commit(commandBuffer: VkMetalCommandBuffer) {
        self.executionQueue.async {
            let device = self._device.device
            let fence = commandBuffer.getFence()

            self.deviceQueue.submit(waitSemaphores: [],
                                    waitDstStageMask: [],
                                    commandBuffers: [ commandBuffer.getCommandBuffer() ],
                                    signalSemaphores: [],
                                    fence: fence)
            commandBuffer.setScheduled()

            DispatchQueue.global().async {
                device.waitForFences(fences: [ fence ])
                device.resetFences(fences: [ fence ])
                commandBuffer.setCompleted()
            }
        }
    }

    public func makeCommandBuffer() -> CommandBuffer? {
        return self.executionQueue.sync {
            if self.commandBuffers.isEmpty {
                self._device.device.waitIdle()
            }

            return self.commandBuffers.removeValue(forKey: self.commandBuffers.first!.key)
        }
    }

    public func makeCommandBufferWithUnretainedReferences() -> CommandBuffer? {
        return self.makeCommandBuffer()
    }
}
