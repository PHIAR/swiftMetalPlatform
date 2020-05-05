import swiftVulkan
import vulkan
import MetalProtocols

internal class VkMetalCommandEncoder: VkMetalObject,
                                      CommandEncoder {
    internal let descriptorPool: VulkanDescriptorPool
    internal let commandBuffer: VkMetalCommandBuffer
    internal var descriptorSets: [VulkanDescriptorSet] = []

    internal init(descriptorPool: VulkanDescriptorPool,
                  commandBuffer: VkMetalCommandBuffer) {
        self.descriptorPool = descriptorPool
        self.commandBuffer = commandBuffer
        super.init(device: commandBuffer._device)
    }

    internal func allocateDescriptorSets(descriptorSetLayouts: [VulkanDescriptorSetLayout]) {
        let device = self._device.getDevice()
        let descriptorSets = device.allocateDescriptorSets(descriptorPool: self.descriptorPool,
                                                           setLayouts: descriptorSetLayouts)

        self.commandBuffer.addDescriptorSet(descriptorSets: descriptorSets)
        self.descriptorSets = descriptorSets
    }

    internal func bindDescriptorSet(pipelineBindPoint: VulkanPipelineBindPoint,
                                    pipelineLayout: VulkanPipelineLayout) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.bindDescriptorSets(pipelineBindPoint: pipelineBindPoint,
                                         pipelineLayout: pipelineLayout,
                                         descriptorSets: self.descriptorSets)
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
                      index: Int) {
        let _buffer = buffer.buffer
        let descriptorSet = self.descriptorSets[0]
        let dstBinding = self.getDstBindingIndex(function: function,
                                                 index: index,
                                                 argumentType: .buffer)
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

    internal func set(texture: VkMetalTexture,
                      function: VkMetalFunction,
                      index: Int) {
        let image = texture.getImage()
        let descriptorSet = self.descriptorSets[0]
        let dstBinding = self.getDstBindingIndex(function: function,
                                                 index: index,
                                                 argumentType: .image)
        let imageInfo = VkDescriptorImageInfo(sampler: nil,
                                              imageView: image.getImage(),
                                              imageLayout: VK_IMAGE_LAYOUT_GENERAL)

        descriptorSet.writeDescriptorSet(dstBinding: dstBinding,
                                         descriptorType: VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,
                                         imageInfos: [ imageInfo ])
        self.commandBuffer.addTrackedResource(resource: texture)
    }

    public func endEncoding() {
    }
}
