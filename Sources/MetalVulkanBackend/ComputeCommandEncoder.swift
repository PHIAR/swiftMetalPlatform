import vulkan
import swiftVulkan
import MetalProtocols

internal final class VkMetalComputeCommandEncoder: VkMetalCommandEncoder,
                                                   ComputeCommandEncoder {
    private var computePipelineState: VkMetalComputePipelineState? = nil

    internal func allocateDescriptorSet() {
        let computePipelineState = self.computePipelineState!
        let function = computePipelineState.getFunction()
        let descriptorSetLayout = function.getDescriptorSetLayout()

        self.allocateDescriptorSets(descriptorSetLayouts: [ descriptorSetLayout ])
    }

    private func bindDescriptorSet() {
        let computePipelineState = self.computePipelineState!
        let pipelineLayout = computePipelineState.getPipelineLayout()

        self.bindDescriptorSet(pipelineBindPoint: .compute,
                               pipelineLayout: pipelineLayout)
    }

    private func bindPipeline(workgroupSize: Size?) {
        let computePipelineState = self.computePipelineState!
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.bindPipeline(pipelineBindPoint: .compute,
                                   pipeline: computePipelineState.getPipeline(workgroupSize: workgroupSize))
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
        self.allocateDescriptorSet()
    }

    public func dispatchThreads(_ threadsPerGrid: Size,
                                threadsPerThreadgroup: Size) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        self.bindDescriptorSet()
        self.bindPipeline(workgroupSize: threadsPerThreadgroup)
        commandBuffer.dispatch(groupCountX: threadsPerGrid.width,
                               groupCountY: threadsPerGrid.height,
                               groupCountZ: threadsPerGrid.depth)
        self.allocateDescriptorSet()
    }

    func dispatchThreadgroups(indirectBuffer: Buffer,
                              indirectBufferOffset: Int,
                              threadsPerThreadgroup: Size) {
    }

    public func setBuffer(_ buffer: Buffer?,
                          offset: Int,
                          index: Int) {
        guard let _buffer = buffer as? VkMetalBuffer else {
            return
        }

        let computePipelineState = self.computePipelineState!
        let function = computePipelineState.getFunction()

        self.set(buffer: _buffer,
                 function: function,
                 offset: offset,
                 index: index)
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
        let computePipelineState = self.computePipelineState!
        let pipelineLayout = computePipelineState.getPipelineLayout()
        let function = computePipelineState.getFunction()

        self.set(bytes: bytes,
                 function: function,
                 pipelineLayout: pipelineLayout,
                 stageFlags: VK_SHADER_STAGE_COMPUTE_BIT.rawValue,
                 length: length,
                 index: index)
    }

    public func setComputePipelineState(_ state: ComputePipelineState) {
        let computePipelineState = state as! VkMetalComputePipelineState

        self.computePipelineState = computePipelineState
        self.allocateDescriptorSet()
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
