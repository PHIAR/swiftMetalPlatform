public protocol CommandQueue {
    var device: Device { get }
    var label: String? { get nonmutating set }

    func makeCommandBuffer() -> CommandBuffer?

    func makeCommandBufferWithUnretainedReferences() -> CommandBuffer?
}
