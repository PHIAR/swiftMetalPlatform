public enum LibraryError: Error {
    case buildFailure(log: String)
    case failed
}

public protocol Library {
    func makeFunction(name: String) -> Function?

    func makeFunction(name: String,
                      constantValues: FunctionConstantValues) throws -> Function

    func makeFunction(name: String,
                      constantValues: FunctionConstantValues,
                      completionHandler: @escaping (Function?, Error?) -> Void)
}
