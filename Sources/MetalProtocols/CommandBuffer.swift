import Foundation

public protocol CommandBuffer {
    var commandQueue: CommandQueue { get }
    var device: Device { get }
    var label: String? { get nonmutating set }

    func addCompletedHandler(block: @escaping (CommandBuffer) -> Void)

    func addScheduledHandler(block: @escaping (CommandBuffer) -> Void)

    func commit()

    func encodeSignalEvent(_ event: Event,
                           value: UInt64)

    func encodeWaitForEvent(_ event: Event,
                            value: UInt64)

    func enqueue()

    func makeBlitCommandEncoder() -> BlitCommandEncoder?

    func makeComputeCommandEncoder() -> ComputeCommandEncoder?

    func makeRenderCommandEncoder(descriptor: RenderPassDescriptor) -> RenderCommandEncoder?

    func present(_ drawable: Drawable)

    func present(_ drawable: Drawable,
                 afterMinimumDuration: CFTimeInterval)

    func present(_ drawable: Drawable,
                 atTime: CFTimeInterval)

    func waitUntilCompleted()

    func waitUntilScheduled()
}
