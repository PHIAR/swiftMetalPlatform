import swiftVulkan
import Dispatch
import Foundation
import MetalProtocols

internal final class VkMetalLibrary: Library {
    private let device: VkMetalDevice
    private let spirv: [UInt32]

    internal required init(device: VkMetalDevice,
                           spirv: [UInt32]) {
        self.device = device
        self.spirv = spirv
    }

    deinit {
    }

    public func makeFunction(name: String) -> Function? {
        return VkMetalFunction(device: self.device.device,
                               spirv: self.spirv,
                               name: name)
    }

    public func makeFunction(name: String,
                             constantValues: FunctionConstantValues) throws -> Function {
        return VkMetalFunction(device: self.device.device,
                               spirv: self.spirv,
                               name: name,
                               constantValues: constantValues)
    }

    public func makeFunction(name: String,
                             constantValues: FunctionConstantValues,
                             completionHandler: @escaping (Function?, Error?) -> Void) {
        preconditionFailure()
    }
}
