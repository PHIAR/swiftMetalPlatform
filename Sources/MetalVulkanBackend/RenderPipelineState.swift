import MetalProtocols

internal final class VkMetalRenderPipelineState: RenderPipelineState,
                                                 Equatable {
    public static func == (lhs: VkMetalRenderPipelineState,
                           rhs: VkMetalRenderPipelineState) -> Bool {
        return false
    }

    internal init() {
    }
}
