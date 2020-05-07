public protocol ComputeCommandEncoder: CommandEncoder {
    func dispatchThreadgroups(_ threadgroupsPerGrid: Size,
                              threadsPerThreadgroup: Size)

    func dispatchThreads(_ threadsPerGrid: Size,
                         threadsPerThreadgroup: Size)

    func dispatchThreadgroups(indirectBuffer: Buffer,
                              indirectBufferOffset: Int,
                              threadsPerThreadgroup: Size)

    func setBuffer(_ buffer: Buffer?,
                   offset: Int,
                   index: Int)


    func setBuffers(_ buffers: [Buffer?],
                    offsets: [Int],
                    range: Range <Int>)

    func setBytes(_ bytes: UnsafeRawPointer,
                  length: Int,
                  index: Int)

    func setComputePipelineState(_ state: ComputePipelineState)

    func setTexture(_ texture: Texture?,
                    index: Int)

    func setTextures(_ textures: [Texture?],
                     range: Range <Int>)
}
