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

internal extension VertexFormat {
    func toVulkanFormat() -> VulkanFormat {
        switch self {
        case .invalid:
            return .undefined

        case .char:
            return .r8SInt

        case .char2:
            return .r8g8SInt

        case .char3:
            return .r8g8b8SInt

        case .char4:
            return .r8g8b8a8SInt

        case .charNormalized:
            return .r8SNorm

        case .char2Normalized:
            return .r8g8SNorm

        case .char3Normalized:
            return .r8g8b8SNorm

        case .char4Normalized:
            return .r8g8b8a8SNorm

        case .float:
            return .r32SFloat

        case .float2:
            return .r32g32SFloat

        case .float3:
            return .r32g32b32SFloat

        case .float4:
            return .r32g32b32a32SFloat

        case .half:
            return .r16SFloat

        case .half2:
            return .r16g16SFloat

        case .half3:
            return .r16g16b16SFloat

        case .half4:
            return .r16g16b16a16SFloat

        case .int:
            return .r32SInt

        case .int2:
            return .r32g32SInt

        case .int3:
            return .r32g32b32SInt

        case .int4:
            return .r32g32b32a32SInt

        case .int1010102Normalized:
            return .a2r10g10b10SNormPack32

        case .short:
            return .r16SInt

        case .short2:
            return .r16g16SInt

        case .short3:
            return .r16g16b16SInt

        case .short4:
            return .r16g16b16a16SInt

        case .shortNormalized:
            return .r16SNorm

        case .short2Normalized:
            return .r16g16SNorm

        case .short3Normalized:
            return .r16g16b16SNorm

        case .short4Normalized:
            return .r16g16b16a16SNorm

        case .uchar:
            return .r8UInt

        case .uchar2:
            return .r8g8UInt

        case .uchar3:
            return .r8g8b8UInt

        case .uchar4:
            return .r8g8b8a8UInt

        case .ucharNormalized:
            return .r8UNorm

        case .uchar2Normalized:
            return .r8g8UNorm

        case .uchar3Normalized:
            return .r8g8b8UNorm

        case .uchar4Normalized:
            return .r8g8b8a8UNorm

        case .uchar4Normalized_bgra:
            return .b8g8r8a8UNorm

        case .uint:
            return .r32UInt

        case .uint2:
            return .r32g32UInt

        case .uint3:
            return .r32g32b32UInt

        case .uint4:
            return .r32g32b32a32UInt

        case .uint1010102Normalized:
            return .a2r10g10b10UNormPack32

        case .ushort:
            return .r16UInt

        case .ushort2:
            return .r16g16UInt

        case .ushort3:
            return .r16g16b16UInt

        case .ushort4:
            return .r16g16b16a16UInt

        case .ushortNormalized:
            return .r16UNorm

        case .ushort2Normalized:
            return .r16g16UNorm

        case .ushort3Normalized:
            return .r16g16b16UNorm

        case .ushort4Normalized:
            return .r16g16b16a16UNorm
        }
    }
}

internal extension VertexAttributeDescriptorArray {
    func getVkVertexInputAttributeDescriptions() -> [VkVertexInputAttributeDescription] {
        var attributes: [VkVertexInputAttributeDescription] = []

        for descriptor in self.descriptors {
            var _attribute = VkVertexInputAttributeDescription()

            _attribute.location = UInt32(descriptor.bufferIndex)
            _attribute.binding = UInt32(descriptor.bufferIndex)
            _attribute.format = descriptor.format.toVulkanFormat().toVkFormat()
            _attribute.offset = UInt32(descriptor.offset)
            attributes.append(_attribute)
        }

        return attributes
    }
}

internal extension VertexBufferLayoutDescriptorArray {
    func getVkVertexInputBindingDescriptions() -> [VkVertexInputBindingDescription] {
        var bindings: [VkVertexInputBindingDescription] = []

        for descriptor in self.descriptors {
            var binding = VkVertexInputBindingDescription()

            switch descriptor.stepFunction {
            case .perInstance:
                binding.inputRate = VK_VERTEX_INPUT_RATE_INSTANCE

            case .perVertex:
                binding.inputRate = VK_VERTEX_INPUT_RATE_VERTEX

            default:
                preconditionFailure()
            }

            binding.binding = UInt32(bindings.count)
            binding.stride = UInt32(binding.stride)
            bindings.append(binding)
        }

        return bindings
    }
}

internal extension VertexDescriptor {
    func getVkVertexInputAttributeDescriptions() -> [VkVertexInputAttributeDescription] {
        return self.attributes.getVkVertexInputAttributeDescriptions()
    }

    func getVkVertexInputBindingDescriptions() -> [VkVertexInputBindingDescription] {
        return self.layouts.getVkVertexInputBindingDescriptions()
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
