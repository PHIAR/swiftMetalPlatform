import swiftVulkan
import vulkan
import Foundation
import MetalProtocols
import SPIRVCross
import SPIRVReflect

internal final class VkMetalFunction: Function {
    private let name: String
    private let shaderModule: VulkanShaderModule
    private let constantValues: FunctionConstantValues?
    private let descriptorSetLayout: VulkanDescriptorSetLayout

    internal convenience init(device: VulkanDevice,
                              spirv: [UInt32],
                              name: String,
                              constantValues: FunctionConstantValues? = nil) {
        let shaderModule = device.createShaderModule(code: spirv.withUnsafeBufferPointer { Data(buffer: $0) })
        let _ = spirv.withUnsafeBytes {
            var descriptorSetLayout = spirv_descriptor_set_layout_t()
            let success = spirvReflectCreateDescriptorSetLayout($0.baseAddress!.assumingMemoryBound(to: UInt32.self),
                                                                spirv.count,
                                                                &descriptorSetLayout)

            precondition(success)

            spirvReflectDestroyDescriptorSetLayout(&descriptorSetLayout)
        }
        let _descriptorSetLayout = device.createDescriptorSetLayout(flags: VK_DESCRIPTOR_SET_LAYOUT_CREATE_UPDATE_AFTER_BIND_POOL_BIT_EXT.rawValue,
                                                                    bindings: [])

        self.init(name: name,
                  shaderModule: shaderModule,
                  constantValues: constantValues,
                  descriptorSetLayout:  _descriptorSetLayout)
    }

    internal required init(name: String,
                           shaderModule: VulkanShaderModule,
                           constantValues: FunctionConstantValues? = nil,
                           descriptorSetLayout: VulkanDescriptorSetLayout) {
        self.name = name
        self.shaderModule = shaderModule
        self.constantValues = constantValues
        self.descriptorSetLayout = descriptorSetLayout
    }

    public func clone() -> VkMetalFunction? {
        return VkMetalFunction(name: self.name,
                               shaderModule: self.shaderModule,
                               constantValues: self.constantValues,
                               descriptorSetLayout: self.descriptorSetLayout)
    }
}
