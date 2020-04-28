import swiftVulkan
import vulkan
import Foundation
import MetalProtocols
import SPIRVCross
import SPIRVReflect

internal extension spirv_specialization_constant_t {
    func toVkSpecializationMapEntry() -> VkSpecializationMapEntry {
        var specializationMapEntry = VkSpecializationMapEntry()

        specializationMapEntry.constantID = self.id
        specializationMapEntry.offset = UInt32(self.offset)
        specializationMapEntry.size = self.size
        return specializationMapEntry
    }
}

internal final class VkMetalFunction: Function {
    private let entryPoint: String
    private let shaderModule: VulkanShaderModule
    private let constantValues: FunctionConstantValues?
    private let descriptorSetLayout: VulkanDescriptorSetLayout
    private let pushConstantRange: VkPushConstantRange
    private let pushConstantDescriptors: [spirv_push_constant_descriptor_t]
    private let functionArgumentTypes: FunctionArgumentTypes
    private let workgroupSize: [VkSpecializationMapEntry]?

    internal convenience init(device: VulkanDevice,
                              spirv: [UInt32],
                              name: String,
                              functionArgumentTypes: FunctionArgumentTypes = [],
                              constantValues: FunctionConstantValues? = nil) {
        var entryPoint = ""
        let shaderModule = device.createShaderModule(code: spirv.withUnsafeBufferPointer { Data(buffer: $0) })
        let (bindings: bindings,
             pushConstantRange: pushConstantRange,
             pushConstantDescriptors: pushConstantDescriptors,
             workgroupSize: workgroupSize): (bindings: [VulkanDescriptorSetLayoutBinding],
                                             pushConstantRange: VkPushConstantRange,
                                             pushConstantDescriptors: [spirv_push_constant_descriptor_t],
                                             workgroupSize: [VkSpecializationMapEntry]?) = spirv.withUnsafeBytes { _spirv in
            var descriptorSetLayout = spirv_descriptor_set_layout_t()
            let success = name.withCString { spirvReflectCreateDescriptorSetLayout($0,
                                                                                   _spirv.baseAddress!.assumingMemoryBound(to: UInt32.self),
                                                                                   spirv.count,
                                                                                   &descriptorSetLayout) }

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

            let pushConstantDescriptors = Array(UnsafeBufferPointer(start: descriptorSetLayout.pushConstantDescriptors,
                                                                    count: descriptorSetLayout.pushConstantDescriptorCount))
            let workgroupSize: [VkSpecializationMapEntry]? = (descriptorSetLayout.workgroupSize.0.size == 0) ? nil : [
                descriptorSetLayout.workgroupSize.0,
                descriptorSetLayout.workgroupSize.1,
                descriptorSetLayout.workgroupSize.2,
            ].map { $0.toVkSpecializationMapEntry() }

            spirvReflectDestroyDescriptorSetLayout(&descriptorSetLayout)
            return (bindings: bindings,
                    pushConstantRange: descriptorSetLayout.pushConstantRange,
                    pushConstantDescriptors: pushConstantDescriptors,
                    workgroupSize: workgroupSize)
        }

        let _descriptorSetLayout = device.createDescriptorSetLayout(bindings: bindings)

        self.init(entryPoint: entryPoint,
                  shaderModule: shaderModule,
                  constantValues: constantValues,
                  descriptorSetLayout:  _descriptorSetLayout,
                  pushConstantRange: pushConstantRange,
                  pushConstantDescriptors: pushConstantDescriptors,
                  functionArgumentTypes: functionArgumentTypes,
                  workgroupSize: workgroupSize)
    }

    internal required init(entryPoint: String,
                           shaderModule: VulkanShaderModule,
                           constantValues: FunctionConstantValues? = nil,
                           descriptorSetLayout: VulkanDescriptorSetLayout,
                           pushConstantRange: VkPushConstantRange,
                           pushConstantDescriptors: [spirv_push_constant_descriptor_t],
                           functionArgumentTypes: FunctionArgumentTypes,
                           workgroupSize: [VkSpecializationMapEntry]?) {
        self.entryPoint = entryPoint
        self.shaderModule = shaderModule
        self.constantValues = constantValues
        self.descriptorSetLayout = descriptorSetLayout
        self.pushConstantRange = pushConstantRange
        self.pushConstantDescriptors = pushConstantDescriptors
        self.functionArgumentTypes = functionArgumentTypes
        self.workgroupSize = workgroupSize
    }

    public func clone() -> VkMetalFunction? {
        return VkMetalFunction(entryPoint: self.entryPoint,
                               shaderModule: self.shaderModule,
                               constantValues: self.constantValues,
                               descriptorSetLayout: self.descriptorSetLayout,
                               pushConstantRange: self.pushConstantRange,
                               pushConstantDescriptors: self.pushConstantDescriptors,
                               functionArgumentTypes: self.functionArgumentTypes,
                               workgroupSize: self.workgroupSize)
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

    public func getPushConstantRange() -> VkPushConstantRange {
        return self.pushConstantRange
    }

    public func getPushConstantDescriptors() -> [spirv_push_constant_descriptor_t] {
        return self.pushConstantDescriptors
    }

    public func getShaderModule() -> VulkanShaderModule {
        return self.shaderModule
    }

    public func getWorkgroupSize() -> [VkSpecializationMapEntry] {
        return self.workgroupSize ?? []
    }
}
