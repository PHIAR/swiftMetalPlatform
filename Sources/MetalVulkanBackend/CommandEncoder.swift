import MetalProtocols

internal class VkMetalCommandEncoder: VkMetalObject,
                                      CommandEncoder {
    internal let commandBuffer: VkMetalCommandBuffer

    internal init(commandBuffer: VkMetalCommandBuffer) {
        self.commandBuffer = commandBuffer
        super.init(device: commandBuffer.vkDevice)
    }

    public func endEncoding() {
    }
}
