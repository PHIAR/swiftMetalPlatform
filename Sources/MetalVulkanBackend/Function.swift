import MetalProtocols
import SPIRVCross
import SPIRVReflect

internal final class VkMetalFunction: Function {
    private let library: VkMetalLibrary
    private let name: String
    private let constantValues: FunctionConstantValues?

    internal required init(library: VkMetalLibrary,
                           name: String,
                           constantValues: FunctionConstantValues? = nil) {
        self.library = library
        self.name = name
        self.constantValues = constantValues
    }

    deinit {
    }

    public func clone() -> VkMetalFunction? {
        return VkMetalFunction(library: self.library,
                               name: self.name)
    }
}
