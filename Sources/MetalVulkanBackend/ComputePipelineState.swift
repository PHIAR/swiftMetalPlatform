import swiftVulkan
import vulkan
import MetalProtocols

internal final class VkMetalComputePipelineState: ComputePipelineState {
    private let function: VkMetalFunction
    private let pipelineLayout: VulkanPipelineLayout
    private let pipeline: VulkanPipeline

    public var maxTotalThreadsPerThreadgroup: Int {
        let workGroupSize = 0

        return workGroupSize
    }

    public var staticThreadgroupMemoryLength: Int {
        let localMemSize = 0

        return localMemSize
    }

    public var threadExecutionWidth: Int {
        return self.maxTotalThreadsPerThreadgroup
    }

    internal init?(device: VulkanDevice,
                   function: VkMetalFunction) {
        let descriptorSetLayout = function.getDescriptorSetLayout()
        let entryPoint = function.getEntryPoint()
        let shaderModule = function.getShaderModule()
        let pipelineLayout = device.createPipelineLayout(descriptorSetLayouts: [
            descriptorSetLayout,
        ])
        let pipelineStage = VulkanPipelineShaderStage(stage: VK_SHADER_STAGE_COMPUTE_BIT,
                                                      shaderModule: shaderModule,
                                                      name: entryPoint)
        let pipeline = device.createComputePipeline(stage: pipelineStage,
                                                    layout: pipelineLayout)

        self.function = function
        self.pipelineLayout = pipelineLayout
        self.pipeline = pipeline
    }

    internal func getFunction() -> VkMetalFunction {
        return self.function
    }

    internal func getPipeline() -> VulkanPipeline {
        return self.pipeline
    }

    internal func getPipelineLayout() -> VulkanPipelineLayout {
        return self.pipelineLayout
    }
}
