import swiftVulkan
import vulkan
import Foundation
import MetalProtocols
import SPIRVCross
import SPIRVReflect

internal final class VkMetalFunction: Function {
    private let entryPoint: String
    private let shaderModule: VulkanShaderModule
    private let constantValues: FunctionConstantValues?
    private let descriptorSetLayout: VulkanDescriptorSetLayout
    private let pushConstants: [VkPushConstantRange]
    private let functionArgumentTypes: FunctionArgumentTypes

    internal convenience init(device: VulkanDevice,
                              spirv: [UInt32],
                              functionArgumentTypes: FunctionArgumentTypes = [],
                              constantValues: FunctionConstantValues? = nil) {
        var entryPoint = ""
        let shaderModule = device.createShaderModule(code: spirv.withUnsafeBufferPointer { Data(buffer: $0) })
        let (bindings: bindings,
             pushConstants: pushConstants): (bindings: [VulkanDescriptorSetLayoutBinding],
                                             pushConstants: [VkPushConstantRange]) = spirv.withUnsafeBytes {
            var descriptorSetLayout = spirv_descriptor_set_layout_t()
            let success = spirvReflectCreateDescriptorSetLayout($0.baseAddress!.assumingMemoryBound(to: UInt32.self),
                                                                spirv.count,
                                                                &descriptorSetLayout)

            precondition(success)

            entryPoint = String(cString: descriptorSetLayout.entry_point)

            let bindings = UnsafeBufferPointer(start: descriptorSetLayout.bindings,
                                               count: descriptorSetLayout.bindingCount).map { binding in
                return VulkanDescriptorSetLayoutBinding(binding: Int(binding.binding),
                                                        descriptorType: binding.descriptorType,
                                                        descriptorCount: Int(binding.descriptorCount),
                                                        stageFlags: binding.stageFlags,
                                                        immutableSamplers: [])
            }

            let pushConstants = Array(UnsafeBufferPointer(start: descriptorSetLayout.pushConstants,
                                                          count: descriptorSetLayout.pushConstantCount))

            spirvReflectDestroyDescriptorSetLayout(&descriptorSetLayout)
            return (bindings: bindings,
                    pushConstants: pushConstants)
        }
        let _descriptorSetLayout = device.createDescriptorSetLayout(bindings: bindings)

        self.init(entryPoint: entryPoint,
                  shaderModule: shaderModule,
                  constantValues: constantValues,
                  descriptorSetLayout:  _descriptorSetLayout,
                  pushConstants: pushConstants,
                  functionArgumentTypes: functionArgumentTypes)
    }

    internal required init(entryPoint: String,
                           shaderModule: VulkanShaderModule,
                           constantValues: FunctionConstantValues? = nil,
                           descriptorSetLayout: VulkanDescriptorSetLayout,
                           pushConstants: [VkPushConstantRange],
                           functionArgumentTypes: FunctionArgumentTypes) {
        self.entryPoint = entryPoint
        self.shaderModule = shaderModule
        self.constantValues = constantValues
        self.descriptorSetLayout = descriptorSetLayout
        self.pushConstants = pushConstants
        self.functionArgumentTypes = functionArgumentTypes
    }

    public func clone() -> VkMetalFunction? {
        return VkMetalFunction(entryPoint: self.entryPoint,
                               shaderModule: self.shaderModule,
                               constantValues: self.constantValues,
                               descriptorSetLayout: self.descriptorSetLayout,
                               pushConstants: self.pushConstants,
                               functionArgumentTypes: functionArgumentTypes)
    }

    public func getDescriptorSetLayout() -> VulkanDescriptorSetLayout {
        return self.descriptorSetLayout
    }

    public func getEntryPoint() -> String {
        return self.entryPoint
    }

    public func getFunctionArgumentTypes() -> FunctionArgumentTypes {
        return self.functionArgumentTypes
    }

    public func getPushConstants() -> [VkPushConstantRange] {
        return self.pushConstants
    }

    public func getShaderModule() -> VulkanShaderModule {
        return self.shaderModule
    }
}
