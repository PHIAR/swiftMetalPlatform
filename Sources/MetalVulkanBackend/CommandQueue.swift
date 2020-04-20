import Dispatch
import MetalProtocols

internal final class VkMetalCommandQueue: VkMetalObject,
                                          CommandQueue {
    internal let executionQueue = DispatchQueue(label: "VkMetalCommandQueue.executionQueue")

    public override var description: String {
        return super.description + " commandQueue:"
    }

    internal override init(device: VkMetalDevice) {
        super.init(device: device)
    }

    deinit {
    }

    public func makeCommandBuffer() -> CommandBuffer? {
        return VkMetalCommandBuffer(commandQueue: self)
    }

    public func makeCommandBufferWithUnretainedReferences() -> CommandBuffer? {
        return VkMetalCommandBuffer(commandQueue: self)
    }
}
