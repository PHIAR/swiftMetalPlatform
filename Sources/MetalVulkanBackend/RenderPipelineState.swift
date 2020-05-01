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

internal final class VkMetalRenderPipelineState: RenderPipelineState,
                                                 Equatable {
    private let device: VulkanDevice
    private let vertexFunction: VkMetalFunction
    private let fragmentFunction: VkMetalFunction
    private let pipelineLayout: VulkanPipelineLayout
    private var specializedPipelines: [DynamicRenderState: VulkanPipeline] = [:]

    public static func == (lhs: VkMetalRenderPipelineState,
                           rhs: VkMetalRenderPipelineState) -> Bool {
        return false
    }

    internal init(device: VulkanDevice,
                  vertexFunction: VkMetalFunction,
                  fragmentFunction: VkMetalFunction) {
        let vertexDescriptorSetLayout = vertexFunction.getDescriptorSetLayout()
        let fragmentDescriptorSetLayout = fragmentFunction.getDescriptorSetLayout()
        let descriptorSetLayouts = [
            vertexDescriptorSetLayout,
            fragmentDescriptorSetLayout,
        ]
        let vertexPushConstantRange = vertexFunction.getPushConstantRange()
        let fragmentPushConstantRange = fragmentFunction.getPushConstantRange()
        let pushConstantRanges = ((vertexPushConstantRange.size == 0) ? [] : [ vertexPushConstantRange ]) +
                                 ((fragmentPushConstantRange.size == 0) ? [] : [ fragmentPushConstantRange ])
        let pipelineLayout = device.createPipelineLayout(descriptorSetLayouts: descriptorSetLayouts,
                                                         pushConstantRanges: pushConstantRanges)


        self.device = device
        self.vertexFunction = vertexFunction
        self.fragmentFunction = fragmentFunction
        self.pipelineLayout = pipelineLayout
    }

    internal func getFragmentFunction() -> VkMetalFunction {
        return self.fragmentFunction
    }

    private func getGraphicsPipeline(renderState: DynamicRenderState,
                                     renderPass: VulkanRenderPass) -> VulkanPipeline {
        if let graphicsPipeline = self.specializedPipelines[renderState] {
            return graphicsPipeline
        }

        let device = self.device
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
        let pipelineLayout = self.getPipelineLayout()
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

        self.specializedPipelines[renderState] = graphicsPipeline
        return graphicsPipeline
    }

    internal func getPipelineLayout() -> VulkanPipelineLayout {
        return self.pipelineLayout
    }

    internal func getVertexFunction() -> VkMetalFunction {
        return self.vertexFunction
    }
}
