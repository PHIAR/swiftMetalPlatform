import swiftVulkan
import vulkan
import MetalProtocols

internal class VkMetalCommandEncoder: VkMetalObject,
                                      CommandEncoder {
    internal let descriptorPool: VulkanDescriptorPool
    internal let commandBuffer: VkMetalCommandBuffer
    internal var descriptorSet: VulkanDescriptorSet? = nil

    internal init(descriptorPool: VulkanDescriptorPool,
                  commandBuffer: VkMetalCommandBuffer) {
        self.descriptorPool = descriptorPool
        self.commandBuffer = commandBuffer
        super.init(device: commandBuffer._device)
    }

    internal func allocateDescriptorSet(descriptorSetLayout: VulkanDescriptorSetLayout) {
        let device = self._device.device
        let descriptorSets = device.allocateDescriptorSets(descriptorPool: self.descriptorPool,
                                                           setLayouts: [ descriptorSetLayout ])

        self.commandBuffer.addDescriptorSet(descriptorSets: descriptorSets)

        self.descriptorSet = descriptorSets[0]
    }

    internal func bindDescriptorSet(pipelineBindPoint: VulkanPipelineBindPoint,
                                    pipelineLayout: VulkanPipelineLayout) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.bindDescriptorSets(pipelineBindPoint: pipelineBindPoint,
                                         pipelineLayout: pipelineLayout,
                                         descriptorSets: [ self.descriptorSet! ])
    }

    internal func getDstBindingIndex(function: VkMetalFunction,
                                     index: Int,
                                     argumentType: FunctionArgumentType) -> Int {
        let functionArgumentTypes = function.getFunctionArgumentTypes()

        guard !functionArgumentTypes.isEmpty else {
            return index
        }

        return (0..<index).reduce(0) { $0 + ((argumentType == functionArgumentTypes[$1]) ? 1 : 0) }
    }

    internal func set(buffer: VkMetalBuffer,
                      function: VkMetalFunction,
                      offset: Int,
                      index: Int,
                      argumentType: FunctionArgumentType) {
        let _buffer = buffer.buffer
        let descriptorSet = self.descriptorSet!
        let dstBinding = self.getDstBindingIndex(function: function,
                                                 index: index,
                                                 argumentType: argumentType)
        let bufferInfo = VkDescriptorBufferInfo(buffer: _buffer.getBuffer(),
                                                offset: VkDeviceSize(offset),
                                                range: VK_WHOLE_SIZE)

        descriptorSet.writeDescriptorSet(dstBinding: dstBinding,
                                         descriptorType: VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                         bufferInfos: [ bufferInfo ])
        self.commandBuffer.addTrackedResource(resource: buffer)
    }

    internal func set(bytes: UnsafeRawPointer,
                      function: VkMetalFunction,
                      pipelineLayout: VulkanPipelineLayout,
                      stageFlags: VkShaderStageFlags,
                      length: Int,
                      index: Int) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()
        let pushConstantDescriptors = function.getPushConstantDescriptors()
        let dstBinding = self.getDstBindingIndex(function: function,
                                                 index: index,
                                                 argumentType: .constant)
        let pushConstantDescriptor = pushConstantDescriptors[dstBinding]

        precondition(length == pushConstantDescriptor.size)

        let values = UnsafeRawBufferPointer(start: bytes,
                                            count: length)

        commandBuffer.pushConstants(layout: pipelineLayout,
                                    stageFlags: stageFlags,
                                    offset: Int(pushConstantDescriptor.offset),
                                    values: values)
    }

    public func endEncoding() {
    }
}
