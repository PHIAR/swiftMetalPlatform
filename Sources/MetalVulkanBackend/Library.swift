import Dispatch
import MetalProtocols

internal final class VkMetalLibrary: Library {
    internal required init(preprocessorOptions: String? = nil) throws {
    }

    deinit {
    }

    public func makeFunction(name: String) -> Function? {
        return VkMetalFunction()
    }

    public func makeFunction(name: String,
                             constantValues: FunctionConstantValues) throws -> Function {
        return VkMetalFunction()
    }

    public func makeFunction(name: String,
                             constantValues: FunctionConstantValues,
                             completionHandler: @escaping (Function?, Error?) -> Void) {
        completionHandler(nil, nil)
    }
}
