import swiftVulkan
import Dispatch
import Foundation
import MetalProtocols

internal final class VkMetalLibrary: Library {
    private let device: VkMetalDevice
    private let shaders: [String: [UInt32]]

    private func getSPIRV(name: String) -> [UInt32]? {
        if self.shaders.count == 1,
           let first = self.shaders.first,
           first.key.isEmpty {
            return first.value
        }

        return self.shaders[name]
    }

    internal required init(device: VkMetalDevice,
                           shaders: [String: [UInt32]]) {
        self.device = device
        self.shaders = shaders
    }

    deinit {
    }

    public func makeFunction(name: String) -> Function? {
        guard let spirv = self.getSPIRV(name: name) else {
            return nil
        }

        return VkMetalFunction(device: self.device.device,
                               spirv: spirv)
    }

    public func makeFunction(name: String,
                             constantValues: FunctionConstantValues) throws -> Function {
        guard let spirv = self.getSPIRV(name: name) else {
            preconditionFailure()
        }

        return VkMetalFunction(device: self.device.device,
                               spirv: spirv,
                               constantValues: constantValues)
    }

    public func makeFunction(name: String,
                             constantValues: FunctionConstantValues,
                             completionHandler: @escaping (Function?, Error?) -> Void) {
        preconditionFailure()
    }
}
