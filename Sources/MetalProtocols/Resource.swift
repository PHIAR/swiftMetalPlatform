public protocol Resource: class {
    var device: Device { get }
    var label: String? { get set }

    var allocatedSize: Int { get }
    var storageMode: StorageMode { get }
}
