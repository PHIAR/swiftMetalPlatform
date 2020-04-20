import MetalProtocols

internal final class VkMetalComputeCommandEncoder: VkMetalCommandEncoder,
                                                   ComputeCommandEncoder {
    var vkComputePipelineState: VkMetalComputePipelineState? = nil

    public func dispatchThreadgroups(_ threadgroupsPerGrid: Size,
                                     threadsPerThreadgroup: Size) {
    }

    public func dispatchThreads(_ threadsPerGrid: Size,
                                threadsPerThreadgroup: Size) {
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
        self.vkComputePipelineState = state as? VkMetalComputePipelineState
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
