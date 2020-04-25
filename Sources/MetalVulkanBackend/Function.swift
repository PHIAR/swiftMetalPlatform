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

    internal convenience init(device: VulkanDevice,
                              spirv: [UInt32],
                              constantValues: FunctionConstantValues? = nil) {
        var entryPoint = ""
        let shaderModule = device.createShaderModule(code: spirv.withUnsafeBufferPointer { Data(buffer: $0) })
        let bindings: [VulkanDescriptorSetLayoutBinding] = spirv.withUnsafeBytes {
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

            spirvReflectDestroyDescriptorSetLayout(&descriptorSetLayout)
            return bindings
        }
        let _descriptorSetLayout = device.createDescriptorSetLayout(flags: VK_DESCRIPTOR_SET_LAYOUT_CREATE_UPDATE_AFTER_BIND_POOL_BIT_EXT.rawValue,
                                                                    bindings: bindings)

        self.init(entryPoint: entryPoint,
                  shaderModule: shaderModule,
                  constantValues: constantValues,
                  descriptorSetLayout:  _descriptorSetLayout)
    }

    internal required init(entryPoint: String,
                           shaderModule: VulkanShaderModule,
                           constantValues: FunctionConstantValues? = nil,
                           descriptorSetLayout: VulkanDescriptorSetLayout) {
        self.entryPoint = entryPoint
        self.shaderModule = shaderModule
        self.constantValues = constantValues
        self.descriptorSetLayout = descriptorSetLayout
    }

    public func clone() -> VkMetalFunction? {
        return VkMetalFunction(entryPoint: self.entryPoint,
                               shaderModule: self.shaderModule,
                               constantValues: self.constantValues,
                               descriptorSetLayout: self.descriptorSetLayout)
    }

    public func getDescriptorSetLayout() -> VulkanDescriptorSetLayout {
        return self.descriptorSetLayout
    }

    public func getEntryPoint() -> String {
        return self.entryPoint
    }

    public func getShaderModule() -> VulkanShaderModule {
        return self.shaderModule
    }
}
