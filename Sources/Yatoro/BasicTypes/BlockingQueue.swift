import Foundation

// TODO: Migrate to Async swift
public class BlockingQueue<T> {
    private var queue = [T]()
    private let semaphore = DispatchSemaphore(value: 0)
    private let accessQueue = DispatchQueue(label: "dev.hermanberdnikov.yatoro.blockingQueue")

    func enqueue(_ element: T) {
        accessQueue.async {
            self.queue.append(element)
            self.semaphore.signal()
        }
    }

    func dequeue() -> T {
        semaphore.wait()
        var element: T?
        accessQueue.sync {
            element = self.queue.removeFirst()
        }
        return element!
    }
}
