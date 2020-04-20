import MetalProtocols

internal final class VkMetalRenderCommandEncoder: VkMetalCommandEncoder,
                                                  RenderCommandEncoder {
    public func setBlendColor(red: Float,
                              green: Float,
                              blue: Float,
                              alpha: Float) {
    }

    public func setCullMode(_ cullMode: MTLCullMode) {
    }

    public func setDepthBias(_ depthBias: Float,
                             slopeScale: Float,
                             clamp: Float) {
    }

    public func setDepthClipMode(_ depthClipMode: DepthClipMode) {
    }

    public func setDepthStencilState(_ depthStencilState: DepthStencilState?) {
    }

    public func setFrontFacing(_ winding: Winding) {
    }

    public func setRenderPipelineState(_ renderPipelineState: RenderPipelineState) {
    }

    public func setScissorRect(_ rect: ScissorRect) {
    }

    public func setScissorRects(_ scissorRects: [ScissorRect]) {
    }

    public func setStencilReferenceValue(_ referenceValue: UInt32) {
    }

    public func setStencilReferenceValues(front frontReferenceValue: UInt32,
                                          back backReferenceValue: UInt32) {
    }

    public func setTriangleFillMode(_ fillMode: TriangleFillMode) {
    }

    public func setViewport(_ viewport: Viewport) {
    }

    public func setViewports(_ viewports: [Viewport]) {
    }

    public func setVertexBuffer(_ buffer: Buffer?,
                                offset: Int,
                                index: Int) {
    }

    public func setVertexBuffers(_ buffers: [Buffer?],
                                 offsets: [Int],
                                 range: Range <Int>) {
    }

    public func setVertexBufferOffset(_ offset: Int,
                                      index: Int) {
    }

    public func setVertexBytes(_ bytes: UnsafeRawPointer,
                               length: Int,
                               index: Int) {
    }

    public func setVertexSamplerState(_ sampler: SamplerState?,
                                      index: Int) {
    }

    public func setVertexSamplerState(_ sampler: SamplerState?,
                                      lodMinClamp: Float,
                                      lodMaxClamp: Float,
                                      index: Int) {
    }

    public func setVertexSamplerStates(_ samplers: [SamplerState?],
                                       range: Range <Int>) {
    }

    public func setVertexSamplerStates(_ samplers: [SamplerState?],
                                       lodMinClamps: [Float],
                                       lodMaxClamps: [Float],
                                       range: Range <Int>) {
    }

    public func setVertexTexture(_ texture: Texture?,
                                 index: Int) {
    }

    public func setVertexTextures(_ textures: [Texture?],
                                  range: Range <Int>) {
    }

    public func setFragmentBuffer(_ buffer: Buffer?,
                                  offset: Int,
                                  index: Int) {
    }

    public func setFragmentBuffers(_ buffers: [Buffer?],
                                   offsets: [Int],
                                   range: Range <Int>) {
    }

    public func setFragmentBufferOffset(_ offset: Int,
                                        index: Int) {
    }

    public func setFragmentBytes(_ bytes: UnsafeRawPointer,
                                 length: Int,
                                 index: Int) {
    }

    public func setFragmentSamplerState(_ sampler: SamplerState?,
                                        index: Int) {
    }

    public func setFragmentSamplerState(_ sampler: SamplerState?,
                                        lodMinClamp: Float,
                                        lodMaxClamp: Float,
                                        index: Int) {
    }

    public func setFragmentSamplerStates(_ samplers: [SamplerState?],
                                         range: Range <Int>) {
    }

    public func setFragmentSamplerStates(_ samplers: [SamplerState?],
                                         lodMinClamps: [Float],
                                         lodMaxClamps: [Float],
                                         range: Range <Int>) {
    }

    public func setFragmentTexture(_ texture: Texture?,
                                   index: Int) {
    }

    public func setFragmentTextures(_ textures: [Texture?],
                                    range: Range <Int>) {
    }

    public func drawPrimitives(type primitiveType: PrimitiveType,
                               vertexStart: Int,
                               vertexCount: Int,
                               instanceCount: Int,
                               baseInstance: Int) {
    }

    public func drawPrimitives(type primitiveType: PrimitiveType,
                               vertexStart: Int,
                               vertexCount: Int,
                               instanceCount: Int) {
    }

    public func drawPrimitives(type primitiveType: PrimitiveType,
                               vertexStart: Int,
                               vertexCount: Int) {
    }

    public func drawIndexedPrimitives(type primitiveType: PrimitiveType,
                                      indexCount: Int,
                                      indexType: IndexType,
                                      indexBuffer: Buffer,
                                      indexBufferOffset: Int,
                                      instanceCount: Int,
                                      baseVertex: Int,
                                      baseInstance: Int) {
    }

    public func drawIndexedPrimitives(type primitiveType: PrimitiveType,
                                      indexCount: Int,
                                      indexType: IndexType,
                                      indexBuffer: Buffer,
                                      indexBufferOffset: Int,
                                      instanceCount: Int) {
    }

    public func drawIndexedPrimitives(type primitiveType: PrimitiveType,
                                      indexCount: Int,
                                      indexType: IndexType,
                                      indexBuffer: Buffer,
                                      indexBufferOffset: Int) {
    }
}
