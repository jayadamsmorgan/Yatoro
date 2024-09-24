import Foundation

public actor BlockingQueue<T> {
    private var queue = [T]()
    private var continuations: [CheckedContinuation<T, Never>] = []

    public init() {}

    public func enqueue(_ element: T) {
        if !continuations.isEmpty {
            let continuation = continuations.removeFirst()
            continuation.resume(returning: element)
        } else {
            queue.append(element)
        }
    }

    public func dequeue() async -> T {
        if !queue.isEmpty {
            return queue.removeFirst()
        } else {
            return await withCheckedContinuation {
                (continuation: CheckedContinuation<T, Never>) in
                continuations.append(continuation)
            }
        }
    }
}
