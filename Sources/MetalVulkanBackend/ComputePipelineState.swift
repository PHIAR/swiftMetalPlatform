import MetalProtocols

internal final class VkMetalComputePipelineState: ComputePipelineState {
    internal let function: VkMetalFunction

    public var maxTotalThreadsPerThreadgroup: Int {
        let workGroupSize = 0

        return workGroupSize
    }

    public var staticThreadgroupMemoryLength: Int {
        let localMemSize = 0

        return localMemSize
    }

    public var threadExecutionWidth: Int {
        return self.maxTotalThreadsPerThreadgroup
    }

    internal init?(function: VkMetalFunction) {
        self.function = function
    }
}
