import swiftVulkan
import CoreFoundation
import Dispatch
import MetalProtocols

internal extension LoadAction {
    func toVkAttachmentLoadOp() -> VulkanAttachmentLoadOp {
        switch self {
        case .clear:
            return .clear

        case .dontCare:
            return .dontCare

        case .load:
            return .load
        }
    }
}

internal extension StoreAction {
    func toVkAttachmentStoreOp() -> VulkanAttachmentStoreOp {
        switch self {
        case .dontCare:
            return .dontCare

        case .store:
            return .store

        default:
            preconditionFailure()
        }
    }
}

internal class VkMetalCommandBuffer: VkMetalObject,
                                     CommandBuffer {
    private enum State {
        case completed
        case recording
        case submitted
    }

    private let _commandQueue: VkMetalCommandQueue
    private let descriptorPool: VulkanDescriptorPool
    private let commandBuffer: VulkanCommandBuffer
    private let fence: VulkanFence
    private let index: Int
    private let retained: Bool
    private var state = State.recording
    private let executionQueue = DispatchQueue(label: "VkMetalCommandBuffer.executionQueue")
    private let scheduledGroup = DispatchGroup()
    private let completionGroup = DispatchGroup()
    private var descriptorSets: [VulkanDescriptorSet] = []
    private var trackedResources: [Resource] = []
    private var trackedEvents: [VulkanEvent] = []
    private var sharedEvents: Set <VkMetalSharedEvent> = []

    public var commandQueue: CommandQueue {
        return self._commandQueue
    }

    internal init(commandQueue: VkMetalCommandQueue,
                  descriptorPool: VulkanDescriptorPool,
                  commandBuffer: VulkanCommandBuffer,
                  index: Int,
                  retained: Bool = true) {
        let device = commandQueue._device
        let _device = device.device
        let fence = _device.createFence()

        self._commandQueue = commandQueue
        self.descriptorPool = descriptorPool
        self.commandBuffer = commandBuffer
        self.fence = fence
        self.index = index
        self.retained = retained
        super.init(device: device)
    }

    internal func addDescriptorSet(descriptorSets: [VulkanDescriptorSet]) {
        self.executionQueue.sync {
            self.descriptorSets += descriptorSets
        }
    }

    internal func addTrackedResource(resource: Resource) {
        guard self.retained else {
            return
        }

        self.executionQueue.sync {
            self.trackedResources.append(resource)
        }
    }

    internal func beginCommandBuffer() {
        self.executionQueue.sync {
            let device = self._device.device

            device.resetFences(fences: [ fence ])

            self.commandBuffer.begin()
            self.scheduledGroup.enter()
            self.completionGroup.enter()

            self.completionGroup.notify(queue: self.executionQueue) {
                self.descriptorSets.removeAll()
                self.trackedEvents.removeAll()
                self.trackedResources.removeAll()
            }
        }
    }

    internal func getCommandBuffer() -> VulkanCommandBuffer {
        return self.commandBuffer
    }

    internal func getFence() -> VulkanFence {
        return self.fence
    }

    internal func getIndex() -> Int {
        return self.index
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
        self.addScheduledHandler { _ in
            self.sharedEvents.forEach { $0.issueListeners() }
        }

        self.addCompletedHandler { _ in
            self.sharedEvents.removeAll()
        }

        self.executionQueue.sync {
            self.commandBuffer.end()
            self._commandQueue.commit(commandBuffer: self)
        }
    }

    public func encodeSignalEvent(_ event: Event,
                                  value: UInt64) {
        self.executionQueue.sync {
            if let sharedEvent = event as? VkMetalSharedEvent,
               let _sharedEvent = sharedEvent.getEvent() {
                self.trackedEvents.append(_sharedEvent)
                self.commandBuffer.set(event: _sharedEvent)
                self.sharedEvents.insert(sharedEvent)
            }
        }
    }

    public func encodeWaitForEvent(_ event: Event,
                                   value: UInt64) {
    }

    public func enqueue() {
    }

    public func makeBlitCommandEncoder() -> BlitCommandEncoder? {
        return VkMetalBlitCommandEncoder(descriptorPool: self.descriptorPool,
                                         commandBuffer: self)
    }

    public func makeComputeCommandEncoder() -> ComputeCommandEncoder? {
        return self.makeComputeCommandEncoder(dispatchType: .serial)
    }

    public func makeComputeCommandEncoder(dispatchType: DispatchType) -> ComputeCommandEncoder? {
        return VkMetalComputeCommandEncoder(descriptorPool: self.descriptorPool,
                                            commandBuffer: self)
    }

    public func makeRenderCommandEncoder(descriptor: RenderPassDescriptor) -> RenderCommandEncoder? {
        return VkMetalRenderCommandEncoder(descriptorPool: self.descriptorPool,
                                           commandBuffer: self,
                                           descriptor: descriptor)
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
