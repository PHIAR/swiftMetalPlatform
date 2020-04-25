import vulkan
import swiftVulkan
import MetalProtocols

internal final class VkMetalComputeCommandEncoder: VkMetalCommandEncoder,
                                                   ComputeCommandEncoder {
    private var computePipelineState: VkMetalComputePipelineState? = nil

    public func dispatchThreadgroups(_ threadgroupsPerGrid: Size,
                                     threadsPerThreadgroup: Size) {
        let threadsPerGrid = Size(width: threadgroupsPerGrid.width * threadsPerThreadgroup.width,
                                  height: threadgroupsPerGrid.height * threadsPerThreadgroup.height,
                                  depth: threadgroupsPerGrid.depth * threadsPerThreadgroup.depth)
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.dispatch(groupCountX: threadsPerGrid.width,
                               groupCountY: threadsPerGrid.height,
                               groupCountZ: threadsPerGrid.depth)
    }

    public func dispatchThreads(_ threadsPerGrid: Size,
                                threadsPerThreadgroup: Size) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.dispatch(groupCountX: threadsPerGrid.width,
                               groupCountY: threadsPerGrid.height,
                               groupCountZ: threadsPerGrid.depth)
    }

    public func setBuffer(_ buffer: Buffer?,
                          offset: Int,
                          index: Int) {
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

        commandBuffer.bindPipeline(pipelineBindPoint: VK_PIPELINE_BIND_POINT_COMPUTE,
                                   pipeline: computePipelineState.getPipeline())
        self.computePipelineState = computePipelineState
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
