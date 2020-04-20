public protocol RenderCommandEncoder: CommandEncoder {
    func setBlendColor(red: Float,
                       green: Float,
                       blue: Float,
                       alpha: Float)
    func setCullMode(_ cullMode: CullMode)
    func setDepthBias(_ depthBias: Float,
                      slopeScale: Float,
                      clamp: Float)
    func setDepthClipMode(_ depthClipMode: DepthClipMode)
    func setDepthStencilState(_ depthStencilState: DepthStencilState?)
    func setFrontFacing(_ winding: Winding)
    func setRenderPipelineState(_ renderPipelineState: RenderPipelineState)
    func setScissorRect(_ rect: ScissorRect)
    func setScissorRects(_ scissorRects: [ScissorRect])
    func setStencilReferenceValue(_ referenceValue: UInt32)
    func setStencilReferenceValues(front frontReferenceValue: UInt32,
                                   back backReferenceValue: UInt32)
    func setTriangleFillMode(_ fillMode: TriangleFillMode)
    func setViewport(_ viewport: Viewport)
    func setViewports(_ viewports: [Viewport])

    func setVertexBuffer(_ buffer: Buffer?,
                         offset: Int,
                         index: Int)
    func setVertexBuffers(_ buffers: [Buffer?],
                          offsets: [Int],
                          range: Range <Int>)
    func setVertexBufferOffset(_ offset: Int,
                               index: Int)
    func setVertexBytes(_ bytes: UnsafeRawPointer,
                        length: Int,
                        index: Int)
    func setVertexSamplerState(_ sampler: SamplerState?,
                               index: Int)
    func setVertexSamplerState(_ sampler: SamplerState?,
                               lodMinClamp: Float,
                               lodMaxClamp: Float,
                               index: Int)
    func setVertexSamplerStates(_ samplers: [SamplerState?],
                                range: Range <Int>)
    func setVertexSamplerStates(_ samplers: [SamplerState?],
                                lodMinClamps: [Float],
                                lodMaxClamps: [Float],
                                range: Range <Int>)
    func setVertexTexture(_ texture: Texture?,
                          index: Int)
    func setVertexTextures(_ textures: [Texture?],
                           range: Range <Int>)

    func setFragmentBuffer(_ buffer: Buffer?,
                           offset: Int,
                           index: Int)
    func setFragmentBuffers(_ buffers: [Buffer?],
                            offsets: [Int],
                            range: Range <Int>)
    func setFragmentBufferOffset(_ offset: Int,
                                 index: Int)
    func setFragmentBytes(_ bytes: UnsafeRawPointer,
                          length: Int,
                          index: Int)
    func setFragmentSamplerState(_ sampler: SamplerState?,
                                 index: Int)
    func setFragmentSamplerState(_ sampler: SamplerState?,
                                 lodMinClamp: Float,
                                 lodMaxClamp: Float,
                                 index: Int)
    func setFragmentSamplerStates(_ samplers: [SamplerState?],
                                  range: Range <Int>)
    func setFragmentSamplerStates(_ samplers: [SamplerState?],
                                  lodMinClamps: [Float],
                                  lodMaxClamps: [Float],
                                  range: Range <Int>)
    func setFragmentTexture(_ texture: Texture?,
                            index: Int)
    func setFragmentTextures(_ textures: [Texture?],
                             range: Range <Int>)

    func drawPrimitives(type primitiveType: PrimitiveType,
                        vertexStart: Int,
                        vertexCount: Int,
                        instanceCount: Int,
                        baseInstance: Int)
    func drawPrimitives(type primitiveType: PrimitiveType,
                        vertexStart: Int,
                        vertexCount: Int,
                        instanceCount: Int)
    func drawPrimitives(type primitiveType: PrimitiveType,
                        vertexStart: Int,
                        vertexCount: Int)
    func drawIndexedPrimitives(type primitiveType: PrimitiveType,
                               indexCount: Int,
                               indexType: IndexType,
                               indexBuffer: Buffer,
                               indexBufferOffset: Int,
                               instanceCount: Int,
                               baseVertex: Int,
                               baseInstance: Int)
    func drawIndexedPrimitives(type primitiveType: PrimitiveType,
                               indexCount: Int,
                               indexType: IndexType,
                               indexBuffer: Buffer,
                               indexBufferOffset: Int,
                               instanceCount: Int)
    func drawIndexedPrimitives(type primitiveType: PrimitiveType,
                               indexCount: Int,
                               indexType: IndexType,
                               indexBuffer: Buffer,
                               indexBufferOffset: Int)
}
