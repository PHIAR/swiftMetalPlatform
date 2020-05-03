import swiftVulkan
import vulkan
import MetalProtocols

internal struct DynamicRenderState: Hashable {
    internal var cullMode: CullMode = .none
    internal var depthClipMode: DepthClipMode = .clip
    internal var winding: Winding = .counterClockwise
    internal var fillMode: TriangleFillMode = .fill
}

internal extension DynamicRenderState {
    func getVulkanCullModeFlags() -> VulkanCullModeFlags {
        switch self.cullMode {
        case .back:
            return .back

        case .front:
            return .front

        case .none:
            return .none
        }
    }

    func getVulkanFrontFace() -> VulkanFrontFace {
        switch self.winding {
        case .clockwise:
            return .clockwise

        case .counterClockwise:
            return .counterClockwise
        }
    }

    func getVulkanPolygonMode() -> VulkanPolygonMode {
        switch self.fillMode {
        case .fill:
            return .fill

        case .lines:
            return .line
        }
    }
}

internal extension VertexDescriptor {
    func getVkVertexInputAttributeDescriptions() -> [VkVertexInputAttributeDescription] {
        return []
    }

    func getVkVertexInputBindingDescriptions() -> [VkVertexInputBindingDescription] {
        return []
    }
}

internal final class VkMetalRenderPipelineState: RenderPipelineState,
                                                 Equatable {
    private static let dynamicStates: [VulkanDynamicState] = [
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

    private let device: VulkanDevice
    private let vertexFunction: VkMetalFunction
    private let fragmentFunction: VkMetalFunction
    private let pipelineLayout: VulkanPipelineLayout
    private var specializedPipelines: [DynamicRenderState: VulkanPipeline] = [:]
    private let vertexInputState: VulkanPipelineVertexInputState
    private let viewportState: VulkanPipelineViewportState

    public static func == (lhs: VkMetalRenderPipelineState,
                           rhs: VkMetalRenderPipelineState) -> Bool {
        return false
    }

    internal init(device: VulkanDevice,
                  vertexDescriptor: VertexDescriptor?,
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
        let attributes = vertexDescriptor?.getVkVertexInputAttributeDescriptions() ?? []
        let bindings = vertexDescriptor?.getVkVertexInputBindingDescriptions() ?? []
        let vertexInputState = VulkanPipelineVertexInputState(attributes: attributes,
                                                              bindings: bindings)
        let viewportState = VulkanPipelineViewportState(viewports: [],
                                                        scissors: [])

        self.device = device
        self.vertexFunction = vertexFunction
        self.fragmentFunction = fragmentFunction
        self.pipelineLayout = pipelineLayout
        self.vertexInputState = vertexInputState
        self.viewportState = viewportState
    }

    internal func getFragmentFunction() -> VkMetalFunction {
        return self.fragmentFunction
    }

    internal func getGraphicsPipeline(topology: VulkanPrimitiveTopology,
                                      renderState: DynamicRenderState,
                                      renderPass: VulkanRenderPass) -> VulkanPipeline {
        if let graphicsPipeline = self.specializedPipelines[renderState] {
            return graphicsPipeline
        }

        let device = self.device
        let stages: [VulkanPipelineShaderStage] = []
        let inputAssemblyState = VulkanPipelineInputAssemblyState(topology: topology,
                                                                  primitiveRestartEnable: false)
        let rasterizationState = VulkanPipelineRasterizationState(depthClampEnable: false,
                                                                  rasterizerDiscardEnable: false,
                                                                  polygonMode: renderState.getVulkanPolygonMode(),
                                                                  cullMode: renderState.getVulkanCullModeFlags(),
                                                                  frontFace: renderState.getVulkanFrontFace(),
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
        let pipelineLayout = self.getPipelineLayout()
        let graphicsPipeline = device.createGraphicsPipeline(stages: stages,
                                                             vertexInputState: self.vertexInputState,
                                                             inputAssemblyState: inputAssemblyState,
                                                             viewportState: self.viewportState,
                                                             rasterizationState: rasterizationState,
                                                             multisampleState: multisampleState,
                                                             colorBlendState: colorBlendState,
                                                             dynamicStates: VkMetalRenderPipelineState.dynamicStates,
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
