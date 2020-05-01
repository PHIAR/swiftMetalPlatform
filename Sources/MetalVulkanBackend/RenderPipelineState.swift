import swiftVulkan
import vulkan
import MetalProtocols

internal final class VkMetalRenderPipelineState: RenderPipelineState,
                                                 Equatable {
    private let vertexFunction: VkMetalFunction
    private let fragmentFunction: VkMetalFunction
    private let pipelineLayout: VulkanPipelineLayout

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


        self.vertexFunction = vertexFunction
        self.fragmentFunction = fragmentFunction
        self.pipelineLayout = pipelineLayout
    }

    internal func getFragmentFunction() -> VkMetalFunction {
        return self.fragmentFunction
    }

    internal func getPipelineLayout() -> VulkanPipelineLayout {
        return self.pipelineLayout
    }

    internal func getVertexFunction() -> VkMetalFunction {
        return self.vertexFunction
    }
}
