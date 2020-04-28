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

    private func bindPipeline(workgroupSize: Size?) {
        let computePipelineState = self.computePipelineState!
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.bindPipeline(pipelineBindPoint: VK_PIPELINE_BIND_POINT_COMPUTE,
                                   pipeline: computePipelineState.getPipeline(workgroupSize: workgroupSize))
    }

    private func getEffectiveBufferIndex(function: VkMetalFunction,
                                         index: Int,
                                         argumentType: FunctionArgumentType) -> Int {
        // NB: Buffers and POD types are interleaved in CL but are separated in
        //     Vulkan into storage buffers and push constants.

        let functionArgumentTypes = function.getFunctionArgumentTypes()

        guard !functionArgumentTypes.isEmpty else {
            return index
        }

        return (0..<index).reduce(0) { $0 + ((argumentType == functionArgumentTypes[$1]) ? 1 : 0) }
    }

    public func dispatchThreadgroups(_ threadgroupsPerGrid: Size,
                                     threadsPerThreadgroup: Size) {
        let threadsPerGrid = Size(width: threadgroupsPerGrid.width * threadsPerThreadgroup.width,
                                  height: threadgroupsPerGrid.height * threadsPerThreadgroup.height,
                                  depth: threadgroupsPerGrid.depth * threadsPerThreadgroup.depth)
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        self.bindDescriptorSet()
        self.bindPipeline(workgroupSize: threadsPerThreadgroup)
        commandBuffer.dispatch(groupCountX: threadsPerGrid.width,
                               groupCountY: threadsPerGrid.height,
                               groupCountZ: threadsPerGrid.depth)
    }

    public func dispatchThreads(_ threadsPerGrid: Size,
                                threadsPerThreadgroup: Size) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        self.bindDescriptorSet()
        self.bindPipeline(workgroupSize: threadsPerThreadgroup)
        commandBuffer.dispatch(groupCountX: threadsPerGrid.width,
                               groupCountY: threadsPerGrid.height,
                               groupCountZ: threadsPerGrid.depth)
    }

    public func setBuffer(_ buffer: Buffer?,
                          offset: Int,
                          index: Int) {
        let computePipelineState = self.computePipelineState!
        let _buffer = buffer as! VkMetalBuffer
        let descriptorSet = self.descriptorSet!
        let dstBinding = self.getEffectiveBufferIndex(function: computePipelineState.getFunction(),
                                                      index: index,
                                                      argumentType: .buffer)
        let bufferInfo = VkDescriptorBufferInfo(buffer: _buffer.buffer.getBuffer(),
                                                offset: VkDeviceSize(offset),
                                                range: VK_WHOLE_SIZE)

        descriptorSet.writeDescriptorSet(dstBinding: dstBinding,
                                         descriptorType: VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                                         bufferInfos: [ bufferInfo ])
        self.commandBuffer.addTrackedResource(resource: _buffer)
    }

    public func setBuffers(_ buffers: [Buffer?],
                           offsets: [Int],
                           range: Range <Int>) {
        precondition(buffers.count == range.count)

        for i in 0..<range.count {
            let buffer = buffers[i]
            let offset = offsets[i]

            self.setBuffer(buffer,
                           offset: offset,
                           index: range.startIndex + i)
        }
    }

    public func setBytes(_ bytes: UnsafeRawPointer,
                         length: Int,
                         index: Int) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()
        let computePipelineState = self.computePipelineState!
        let pipelineLayout = computePipelineState.getPipelineLayout()
        let function = computePipelineState.getFunction()
        let pushConstantDescriptors = function.getPushConstantDescriptors()
        let dstBinding = self.getEffectiveBufferIndex(function: computePipelineState.getFunction(),
                                                      index: index,
                                                      argumentType: .constant)
        let pushConstantDescriptor = pushConstantDescriptors[dstBinding]

        precondition(length == pushConstantDescriptor.size)

        let values = UnsafeRawBufferPointer(start: bytes,
                                            count: length)

        commandBuffer.pushConstants(layout: pipelineLayout,
                                    stageFlags: VK_SHADER_STAGE_COMPUTE_BIT.rawValue,
                                    offset: Int(pushConstantDescriptor.offset),
                                    values: values)
    }

    public func setComputePipelineState(_ state: ComputePipelineState) {
        let computePipelineState = state as! VkMetalComputePipelineState
        let function = computePipelineState.getFunction()
        let descriptorSetLayout = function.getDescriptorSetLayout()
        let device = self._device.device
        let descriptorSets = device.allocateDescriptorSets(descriptorPool: self.descriptorPool,
                                                           setLayouts: [ descriptorSetLayout ])

        self.commandBuffer.addDescriptorSet(descriptorSets: descriptorSets)

        self.computePipelineState = computePipelineState
        self.descriptorSet = descriptorSets[0]
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
