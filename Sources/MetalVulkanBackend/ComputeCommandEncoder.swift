import vulkan
import swiftVulkan
import MetalProtocols

internal final class VkMetalComputeCommandEncoder: VkMetalCommandEncoder,
                                                   ComputeCommandEncoder {
    private var computePipelineState: VkMetalComputePipelineState? = nil
    private var descriptorSet: VulkanDescriptorSet? = nil

    private func bindDescriptorSet() {
        let computePipelineState = self.computePipelineState!
        let pipelineLayout = computePipelineState.getPipelineLayout()
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.bindDescriptorSets(pipelineBindPoint: VK_PIPELINE_BIND_POINT_COMPUTE,
                                         pipelineLayout: pipelineLayout,
                                         descriptorSets: [ self.descriptorSet! ])
    }

    public func dispatchThreadgroups(_ threadgroupsPerGrid: Size,
                                     threadsPerThreadgroup: Size) {
        let threadsPerGrid = Size(width: threadgroupsPerGrid.width * threadsPerThreadgroup.width,
                                  height: threadgroupsPerGrid.height * threadsPerThreadgroup.height,
                                  depth: threadgroupsPerGrid.depth * threadsPerThreadgroup.depth)
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        self.bindDescriptorSet()
        commandBuffer.dispatch(groupCountX: threadsPerGrid.width,
                               groupCountY: threadsPerGrid.height,
                               groupCountZ: threadsPerGrid.depth)
    }

    public func dispatchThreads(_ threadsPerGrid: Size,
                                threadsPerThreadgroup: Size) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        self.bindDescriptorSet()
        commandBuffer.dispatch(groupCountX: threadsPerGrid.width,
                               groupCountY: threadsPerGrid.height,
                               groupCountZ: threadsPerGrid.depth)
    }

    public override func endEncoding() {
    }

    public func setBuffer(_ buffer: Buffer?,
                          offset: Int,
                          index: Int) {
        let device = self._device.device
        let _buffer = buffer as! VkMetalBuffer
        let descriptorSet = self.descriptorSet!
        let bufferInfo = VkDescriptorBufferInfo(buffer: _buffer.buffer.getBuffer(),
                                                offset: VkDeviceSize(offset),
                                                range: VK_WHOLE_SIZE)

        device.writeDescriptorSet(descriptorSet: descriptorSet,
                                  dstBinding: index,
                                  descriptorType: VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                  bufferInfos: [ bufferInfo ])
    }

    public func setBuffers(_ buffers: [Buffer?],
                           offsets: [Int],
                           range: Range <Int>) {
    }

    public func setBytes(_ bytes: UnsafeRawPointer,
                         length: Int,
                         index: Int) {
    }

    public func setComputePipelineState(_ state: ComputePipelineState) {
        let computePipelineState = state as! VkMetalComputePipelineState
        let commandBuffer = self.commandBuffer.getCommandBuffer()
        let function = computePipelineState.getFunction()
        let descriptorSetLayout = function.getDescriptorSetLayout()
        let device = self._device.device
        let descriptorSet = device.allocateDescriptorSets(descriptorPool: self.descriptorPool,
                                                          setLayouts: [ descriptorSetLayout ])

        commandBuffer.bindPipeline(pipelineBindPoint: VK_PIPELINE_BIND_POINT_COMPUTE,
                                   pipeline: computePipelineState.getPipeline())
        self.computePipelineState = computePipelineState
        self.descriptorSet = descriptorSet[0]
    }

    public func setTexture(_ texture: Texture?,
                           index: Int) {
    }

    public func setTextures(_ textures: [Texture?],
                            range: Range <Int>) {
        precondition(textures.count == range.count)

        for i in 0..<range.count {
            let texture = textures[i]

            self.setTexture(texture,
                            index: range.startIndex + i)
        }
    }
}
