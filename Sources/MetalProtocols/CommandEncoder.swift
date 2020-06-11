public protocol CommandEncoder {
    var device: Device { get }
    var label: String? { get nonmutating set }

    func endEncoding()
    func pushDebugGroup(_ string: String)
    func popDebugGroup()
}
