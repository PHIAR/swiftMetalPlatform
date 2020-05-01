import swiftVulkan
import vulkan
import MetalProtocols

internal struct DynamicRenderState {
    internal var cullMode: CullMode = .none
    internal var depthClipMode: DepthClipMode = .clip
    internal var winding: Winding = .counterClockwise
    internal var fillMode: TriangleFillMode = .fill
}

extension DynamicRenderState: Hashable {
}

internal final class VkMetalRenderCommandEncoder: VkMetalCommandEncoder,
                                                  RenderCommandEncoder {
    private var currentRenderState = DynamicRenderState()
    private var renderPass: VulkanRenderPass
    private var graphicsPipelines: [DynamicRenderState: VulkanPipeline] = [:]
    private var renderPipelineState: VkMetalRenderPipelineState? = nil
    private var depthStencilState: DepthStencilState? = nil

    private func getRenderPipeline() -> VulkanPipeline {
        if let graphicsPipeline = self.graphicsPipelines[self.currentRenderState] {
            return graphicsPipeline
        }

        let device = self.commandBuffer._device.device
        let stages: [VulkanPipelineShaderStage] = []
        let vertexInputState = VulkanPipelineVertexInputState()
        let inputAssemblyState = VulkanPipelineInputAssemblyState(topology: VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP,
                                                                  primitiveRestartEnable: false)
        let viewportState = VulkanPipelineViewportState(viewports: [],
                                                        scissors: [])
        let rasterizationState = VulkanPipelineRasterizationState(depthClampEnable: false,
                                                                  rasterizerDiscardEnable: false,
                                                                  polygonMode: .fill,
                                                                  cullMode: .back,
                                                                  frontFace: .counterClockwise,
                                                                  depthBiasEnable: false,
                                                                  depthBiasConstantFactor: 0.0,
                                                                  depthBiasClamp: 0.0,
                                                                  depthBiasSlopeFactor: 0.0,
                                                                  lineWidth: 1.0)
        let multisampleState = VulkanPipelineMultisampleState(rasterizationSamples: VK_SAMPLE_COUNT_1_BIT,
                                                              sampleShadingEnable: false,
                                                              minSampleShading: 0,
                                                              sampleMask: [],
                                                              alphaToCoverageEnable: false,
                                                              alphaToOneEnable: false)
        let colorBlendState = VulkanPipelineColorBlendState(logicOpEnable: false,
                                                            attachments: [])
        let dynamicStates: [VulkanDynamicState] = [
            .blendConstants,
            .depthBias,
            .depthBounds,
            .lineWidth,
            .scissor,
            .stencilCompareMask,
            .stencilReference,
            .stencilWriteMask,
            .viewport,
        ]
        let renderPipelineState = self.renderPipelineState!
        let pipelineLayout = renderPipelineState.getPipelineLayout()
        let renderPass = self.renderPass
        let graphicsPipeline = device.createGraphicsPipeline(stages: stages,
                                                             vertexInputState: vertexInputState,
                                                             inputAssemblyState: inputAssemblyState,
                                                             viewportState: viewportState,
                                                             rasterizationState: rasterizationState,
                                                             multisampleState: multisampleState,
                                                             colorBlendState: colorBlendState,
                                                             dynamicStates: dynamicStates,
                                                             pipelineLayout: pipelineLayout,
                                                             renderPass: renderPass)

        self.graphicsPipelines[self.currentRenderState] = graphicsPipeline
        return graphicsPipeline
    }

    public init(descriptorPool: VulkanDescriptorPool,
                commandBuffer: VkMetalCommandBuffer,
                renderPass: VulkanRenderPass) {
        self.renderPass = renderPass
        super.init(descriptorPool: descriptorPool,
                   commandBuffer: commandBuffer)
    }

    public func setBlendColor(red: Float,
                              green: Float,
                              blue: Float,
                              alpha: Float) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.set(blendConstants: [
            red,
            green,
            blue,
            alpha,
        ])
    }

    public func setCullMode(_ cullMode: CullMode) {
        self.currentRenderState.cullMode = cullMode
    }

    public func setDepthBias(_ depthBias: Float,
                             slopeScale: Float,
                             clamp: Float) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.set(depthBiasConstantFactor: depthBias,
                          depthBiasClamp: clamp,
                          depthBiasSlopeFactor: slopeScale)
    }

    public func setDepthClipMode(_ depthClipMode: DepthClipMode) {
        self.currentRenderState.depthClipMode = depthClipMode
    }

    public func setDepthStencilState(_ depthStencilState: DepthStencilState?) {
        self.depthStencilState = depthStencilState
    }

    public func setFrontFacing(_ winding: Winding) {
        self.currentRenderState.winding = winding
    }

    public func setRenderPipelineState(_ renderPipelineState: RenderPipelineState) {
        let _renderPipelineState = renderPipelineState as! VkMetalRenderPipelineState

        self.renderPipelineState = _renderPipelineState
    }

    public func setScissorRect(_ rect: ScissorRect) {
        self.setScissorRects([ rect ])
    }

    public func setScissorRects(_ scissorRects: [ScissorRect]) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()
        let scissors = scissorRects.map { VkRect2D(offset: VkOffset2D(x: Int32($0.x),
                                                                      y: Int32($0.y)),
                                                   extent: VkExtent2D(width: UInt32($0.width),
                                                                      height: UInt32($0.height))) }

        commandBuffer.setScissor(scissors: scissors)
    }

    public func setStencilReferenceValue(_ referenceValue: UInt32) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.setStencilCompareMask(faceMask: VK_STENCIL_FACE_FRONT_AND_BACK.rawValue,
                                            compareMask: referenceValue)
    }

    public func setStencilReferenceValues(front frontReferenceValue: UInt32,
                                          back backReferenceValue: UInt32) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.setStencilCompareMask(faceMask: VK_STENCIL_FACE_FRONT_BIT.rawValue,
                                            compareMask: frontReferenceValue)
        commandBuffer.setStencilCompareMask(faceMask: VK_STENCIL_FACE_BACK_BIT.rawValue,
                                            compareMask: backReferenceValue)
    }

    public func setTriangleFillMode(_ fillMode: TriangleFillMode) {
        self.currentRenderState.fillMode = fillMode
    }

    public func setViewport(_ viewport: Viewport) {
        self.setViewports([ viewport ])
    }

    public func setViewports(_ viewports: [Viewport]) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()
        let _viewports = viewports.map { VkViewport(x: Float($0.originX),
                                                    y: Float($0.originY),
                                                    width: Float($0.width),
                                                    height: Float($0.height),
                                                    minDepth: Float($0.znear),
                                                    maxDepth: Float($0.zfar)) }

        commandBuffer.setViewport(viewports: _viewports)
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
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.draw(vertexCount: vertexCount,
                           instanceCount: instanceCount,
                           firstVertex: vertexStart,
                           firstInstance: baseInstance)
    }

    public func drawPrimitives(type primitiveType: PrimitiveType,
                               vertexStart: Int,
                               vertexCount: Int,
                               instanceCount: Int) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.draw(vertexCount: vertexCount,
                           instanceCount: instanceCount,
                           firstVertex: vertexStart,
                           firstInstance: 0)
    }

    public func drawPrimitives(type primitiveType: PrimitiveType,
                               vertexStart: Int,
                               vertexCount: Int) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.draw(vertexCount: vertexCount,
                           instanceCount: 1,
                           firstVertex: vertexStart,
                           firstInstance: 0)
    }

    public func drawIndexedPrimitives(type primitiveType: PrimitiveType,
                                      indexCount: Int,
                                      indexType: IndexType,
                                      indexBuffer: Buffer,
                                      indexBufferOffset: Int,
                                      instanceCount: Int,
                                      baseVertex: Int,
                                      baseInstance: Int) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.drawIndexed(indexCount: indexCount,
                                  instanceCount: instanceCount,
                                  firstIndex: baseVertex,
                                  vertexOffset: indexBufferOffset,
                                  firstInstance: baseInstance)
    }

    public func drawIndexedPrimitives(type primitiveType: PrimitiveType,
                                      indexCount: Int,
                                      indexType: IndexType,
                                      indexBuffer: Buffer,
                                      indexBufferOffset: Int,
                                      instanceCount: Int) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.drawIndexed(indexCount: indexCount,
                                  instanceCount: instanceCount,
                                  firstIndex: 0,
                                  vertexOffset: indexBufferOffset,
                                  firstInstance: 0)
    }

    public func drawIndexedPrimitives(type primitiveType: PrimitiveType,
                                      indexCount: Int,
                                      indexType: IndexType,
                                      indexBuffer: Buffer,
                                      indexBufferOffset: Int) {
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.drawIndexed(indexCount: indexCount,
                                  instanceCount: 1,
                                  firstIndex: 0,
                                  vertexOffset: indexBufferOffset,
                                  firstInstance: 0)
    }

    public override func endEncoding() {
        let commandBuffer = self.commandBuffer.getCommandBuffer()

        commandBuffer.endRenderPass()
        super.endEncoding()
    }
}
