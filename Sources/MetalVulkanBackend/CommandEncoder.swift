import swiftVulkan
import MetalProtocols

internal class VkMetalCommandEncoder: VkMetalObject,
                                      CommandEncoder {
    internal let descriptorPool: VulkanDescriptorPool
    internal let commandBuffer: VkMetalCommandBuffer

    internal init(descriptorPool: VulkanDescriptorPool,
                  commandBuffer: VkMetalCommandBuffer) {
        self.descriptorPool = descriptorPool
        self.commandBuffer = commandBuffer
        super.init(device: commandBuffer._device)
    }

    public func endEncoding() {
    }
}
