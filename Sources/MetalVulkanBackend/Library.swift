import swiftVulkan
import Dispatch
import Foundation
import MetalProtocols

internal final class VkMetalLibrary: Library {
    private let device: VkMetalDevice
    private let shaderModule: VulkanShaderModule

    internal required init(device: VkMetalDevice,
                           spirv: [UInt32]) {
        let shaderModule = device.device.createShaderModule(code: spirv.withUnsafeBufferPointer { Data(buffer: $0) })

        self.device = device
        self.shaderModule = shaderModule
    }

    deinit {
    }

    public func makeFunction(name: String) -> Function? {
        return VkMetalFunction(library: self,
                               name: name)
    }

    public func makeFunction(name: String,
                             constantValues: FunctionConstantValues) throws -> Function {
        return VkMetalFunction(library: self,
                               name: name,
                               constantValues: constantValues)
    }

    public func makeFunction(name: String,
                             constantValues: FunctionConstantValues,
                             completionHandler: @escaping (Function?, Error?) -> Void) {
        preconditionFailure()
    }
}
