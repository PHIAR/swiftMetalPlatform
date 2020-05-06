import swiftVulkan
import vulkan
import Dispatch
import MetalProtocols

internal final class VkMetalComputePipelineState: ComputePipelineState {
    private let _device: VkMetalDevice
    private let function: VkMetalFunction
    private let pipelineLayout: VulkanPipelineLayout
    private let executionQueue = DispatchQueue(label: "VkMetalComputePipelineState.executionQueue")
    private var specializedPipelines: [Size: VulkanPipeline] = [:]

    public var device: Device {
        return self._device
    }

    public var maxTotalThreadsPerThreadgroup: Int {
        let workGroupSize = 1024

        return workGroupSize
    }

    public var staticThreadgroupMemoryLength: Int {
        let localMemSize = 16384

        return localMemSize
    }

    public var threadExecutionWidth: Int {
        return self.maxTotalThreadsPerThreadgroup
    }

    internal init?(device: VkMetalDevice,
                   function: VkMetalFunction) {
        let _device = device.getDevice()
        let descriptorSetLayout = function.getDescriptorSetLayout()
        let pushConstantRange = function.getPushConstantRange()
        let pipelineLayout = _device.createPipelineLayout(descriptorSetLayouts: [ descriptorSetLayout ],
                                                          pushConstantRanges: (pushConstantRange.size == 0) ? [] : [ pushConstantRange ])

        self._device = device
        self.function = function
        self.pipelineLayout = pipelineLayout
    }

    internal func getFunction() -> VkMetalFunction {
        return self.function
    }

    internal func getPipeline(workgroupSize: Size?) -> VulkanPipeline {
        return self.executionQueue.sync {
            let _workgroupSize = workgroupSize ?? Size(width: 1,
                                                       height: 1,
                                                       depth: 1)
            let specializationData = [
                UInt32(_workgroupSize.width),
                UInt32(_workgroupSize.height),
                UInt32(_workgroupSize.depth),
            ]

            guard let pipeline = self.specializedPipelines[_workgroupSize] else {
                let device = self._device.getDevice()
                let function = self.function
                let shaderModule = function.getShaderModule()
                let entryPoint = function.getEntryPoint()
                let specializationConstants = function.getWorkgroupSize()
                let pipeline: VulkanPipeline = specializationData.withUnsafeBytes {
                    let pipelineStage = VulkanPipelineShaderStage(stage: VK_SHADER_STAGE_COMPUTE_BIT,
                                                                  shaderModule: shaderModule,
                                                                  name: entryPoint,
                                                                  specializationConstants: specializationConstants,
                                                                  specializationData: $0)
                    let pipeline = device.createComputePipeline(stage: pipelineStage,
                                                                layout: pipelineLayout)

                    self.specializedPipelines[_workgroupSize] = pipeline

                    return pipeline
                }

                return pipeline
            }

            return pipeline
        }
    }

    internal func getPipelineLayout() -> VulkanPipelineLayout {
        return self.pipelineLayout
    }
}
