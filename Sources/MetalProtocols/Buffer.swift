public protocol Buffer: Resource {
    var length: Int { get }

    func contents() -> UnsafeMutableRawPointer
}
