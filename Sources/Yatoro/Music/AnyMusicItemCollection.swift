import MusicKit

public protocol AnyMusicItemCollection: Collection {
    func item(at index: Int) -> Element?
}

extension MusicItemCollection: AnyMusicItemCollection
where Element: MusicItem {
    public func item(at index: Int) -> Element? {
        if (0..<self.count).contains(index) {
            return self[index]
        }
        return nil
    }

    public func items(at indices: [Int]) -> [Element] {
        var items: [Element] = []
        for index in indices {
            if let item = item(at: index) {
                items.append(item)
            }
        }
        return items
    }

    public func selectableCollection(with indices: [Int]) -> Self {
        return .init(items(at: indices))
    }
}
