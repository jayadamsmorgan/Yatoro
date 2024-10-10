import Foundation

public protocol SelectablePage: Page, Comparable, Hashable {

    func subSelectables() -> [any SelectablePage]?

    func select() async
    func unselect() async

}

public actor SelectionManager {

    public static let shared: SelectionManager = .init()

    private var selectables: [any SelectablePage] = []

    private var selected: (any SelectablePage)?

    init() {}

    public func clearSelectables() async {
        self.selectables = []
    }

    public func addSelectable(_ newSelectable: any SelectablePage) async {

        guard !selectables.isEmpty else {
            selectables.append(newSelectable)
            return
        }

    }

    public func addSelectables(_ newSelectables: [any SelectablePage]) async {
        for selectable in newSelectables {
            await addSelectable(selectable)
        }
    }

    public func nextSelectable() async {

    }

    public func previousSelectable() async {

    }

    public func upSelectable() async {

    }

    public func downSelectable() async {

    }

    public func leftSelectable() async {

    }

    public func rightSelectable() async {

    }

}
