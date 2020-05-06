import swiftVulkan
import Dispatch
import Foundation
import MetalProtocols

internal final class VkMetalLibrary: Library {
    private let _device: VkMetalDevice
    private let shaders: [String: [UInt32]]
    private let functionsArgumentTypes: [String: FunctionArgumentTypes]

    public var device: Device {
        return self._device
    }

    private func getFunctionCreationParameters(name: String) -> (spirv: [UInt32],
                                                                 functionArgumentTypes: FunctionArgumentTypes)? {
        if self.shaders.count == 1,
           let first = self.shaders.first,
           first.key.isEmpty {
            return (spirv: first.value,
                    functionArgumentTypes: self.functionsArgumentTypes.first?.value ?? [])
        }

        guard let spirv = self.shaders[name] else {
            return nil
        }

        return (spirv: spirv,
                functionArgumentTypes: self.functionsArgumentTypes[name] ?? [])
    }

    internal required init(device: VkMetalDevice,
                           shaders: [String: [UInt32]],
                           functionsArgumentTypes: [String: FunctionArgumentTypes] = [:]) {
        self._device = device
        self.shaders = shaders
        self.functionsArgumentTypes = functionsArgumentTypes
    }

    public func makeFunction(name: String) -> Function? {
        guard let (spirv: spirv,
                   functionArgumentTypes: functionArgumentTypes) = self.getFunctionCreationParameters(name: name) else {
            preconditionFailure()
        }

        return VkMetalFunction(device: self._device.getDevice(),
                               spirv: spirv,
                               name: name,
                               functionArgumentTypes: functionArgumentTypes)
    }

    public func makeFunction(name: String,
                             constantValues: FunctionConstantValues) throws -> Function {
        guard let (spirv: spirv,
                   functionArgumentTypes: functionArgumentTypes) = self.getFunctionCreationParameters(name: name) else {
            preconditionFailure()
        }

        return VkMetalFunction(device: self._device.getDevice(),
                               spirv: spirv,
                               name: name,
                               functionArgumentTypes: functionArgumentTypes,
                               constantValues: constantValues)
    }

    public func makeFunction(name: String,
                             constantValues: FunctionConstantValues,
                             completionHandler: @escaping (Function?, Error?) -> Void) {
        preconditionFailure()
    }
}
