import swiftVulkan
import CoreFoundation
import Dispatch
import MetalProtocols

internal class VkMetalCommandBuffer: VkMetalObject,
                                     CommandBuffer {
    private enum State {
        case completed
        case recording
        case submitted
    }

    private let _commandQueue: VkMetalCommandQueue
    private let commandBuffer: VulkanCommandBuffer
    private let fence: VulkanFence
    private let index: Int
    private var state = State.recording
    private let executionQueue = DispatchQueue(label: "VkMetalCommandBuffer.executionQueue")
    private let scheduledGroup = DispatchGroup()
    private let completionGroup = DispatchGroup()

    public var commandQueue: CommandQueue {
        return self._commandQueue
    }

    internal init(commandQueue: VkMetalCommandQueue,
                  commandBuffer: VulkanCommandBuffer,
                  index: Int) {
        let device = commandQueue._device
        let _device = device.device
        let fence = _device.createFence()

        self._commandQueue = commandQueue
        self.commandBuffer = commandBuffer
        self.fence = fence
        self.index = index
        super.init(device: device)

        _device.resetFences(fences: [ fence ])
        commandBuffer.begin()
        self.scheduledGroup.enter()
        self.completionGroup.enter()
    }

    internal func getCommandBuffer() -> VulkanCommandBuffer {
        return self.commandBuffer
    }

    internal func getFence() -> VulkanFence {
        return self.fence
    }

    internal func setCompleted() {
        self.completionGroup.leave()
    }

    internal func setScheduled() {
        self.scheduledGroup.leave()
    }

    public func addCompletedHandler(block: @escaping (CommandBuffer) -> Void) {
        self.completionGroup.notify(queue: self.executionQueue) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            block(strongSelf)
        }
    }

    public func addScheduledHandler(block: @escaping (CommandBuffer) -> Void) {
        self.scheduledGroup.notify(queue: self.executionQueue) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            block(strongSelf)
        }
    }

    public func commit() {
        self.commandBuffer.end()
        self._commandQueue.commit(commandBuffer: self)
    }

    public func encodeSignalEvent(_ event: Event,
                                  value: UInt64) {
    }

    public func encodeWaitForEvent(_ event: Event,
                                   value: UInt64) {
    }

    public func enqueue() {
    }

    public func makeBlitCommandEncoder() -> BlitCommandEncoder? {
        return VkMetalBlitCommandEncoder(commandBuffer: self)
    }

    public func makeComputeCommandEncoder() -> ComputeCommandEncoder? {
        return self.makeComputeCommandEncoder(dispatchType: .serial)
    }

    public func makeComputeCommandEncoder(dispatchType: DispatchType) -> ComputeCommandEncoder? {
        return VkMetalComputeCommandEncoder(commandBuffer: self)
    }

    public func makeRenderCommandEncoder(descriptor: RenderPassDescriptor) -> RenderCommandEncoder? {
        return VkMetalRenderCommandEncoder(commandBuffer: self)
    }

    public func present(_ drawable: Drawable) {
    }

    public func present(_ drawable: Drawable,
                        afterMinimumDuration: CFTimeInterval) {
    }

    public func present(_ drawable: Drawable,
                        atTime: CFTimeInterval) {
    }

    public func waitUntilCompleted() {
        self.completionGroup.wait()
    }

    public func waitUntilScheduled() {
        self.scheduledGroup.wait()
    }
}
