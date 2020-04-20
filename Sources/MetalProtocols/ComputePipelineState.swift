public enum ComputePipelineStateError: Error {
    case failed
}

public protocol ComputePipelineState {
    var maxTotalThreadsPerThreadgroup: Int { get }
    var staticThreadgroupMemoryLength: Int { get }
    var threadExecutionWidth: Int { get }
}
