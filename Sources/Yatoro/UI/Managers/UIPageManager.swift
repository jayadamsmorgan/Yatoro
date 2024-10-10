import SwiftNotCurses

@MainActor
public struct UIPageManager {

    var layoutRows: UInt32  // From left to right
    var layoutColumns: UInt32  // From top to bottom

    // Basically an array of rows
    var layout: [[Page]]

    var commandPage: CommandPage
    var windowTooSmallPage: WindowTooSmallPage

    public init(
        layoutConfig: Config.UIConfig.UILayoutConfig,
        commandPage: CommandPage,
        windowTooSmallPage: WindowTooSmallPage,
        stdPlane: Plane
    ) async {
        self.commandPage = commandPage
        self.windowTooSmallPage = windowTooSmallPage
        self.layout = []
        self.layoutRows = layoutConfig.rows
        self.layoutColumns = layoutConfig.cols
        for _ in 0..<layoutColumns {
            layout.append([])
        }

        var index = 0
        for i in 0..<Int(layoutColumns) {
            for _ in 0..<Int(layoutRows) {

                if index == layoutConfig.pages.count {
                    return
                }

                let pageType = layoutConfig.pages[index]

                index += 1

                switch pageType {

                case .nowPlaying:
                    guard
                        let nowPlayingPage = NowPlayingPage(
                            stdPlane: stdPlane,
                            state: PageState(
                                absX: 0,
                                absY: 0,
                                width: 28,
                                height: 13
                            )
                        )
                    else {
                        logger?.critical("Failed to initiate Player Page.")
                        UI.running = false
                        return
                    }
                    layout[i].append(nowPlayingPage)

                case .queue:
                    guard
                        let queuePage = QueuePage(
                            stdPlane: stdPlane,
                            state: PageState(
                                absX: 0,
                                absY: 13,
                                width: 28,
                                height: 13
                            )
                        )
                    else {
                        logger?.critical("Failed to initiate Queue Page.")
                        UI.running = false
                        return
                    }
                    layout[i].append(queuePage)

                case .search:
                    guard
                        let searchPage = SearchPage(
                            stdPlane: stdPlane,
                            state: PageState(
                                absX: 30,
                                absY: 0,
                                width: 28,
                                height: 13
                            )
                        )
                    else {
                        logger?.critical("Failed to initiate Search Page.")
                        UI.running = false
                        return
                    }
                    layout[i].append(searchPage)

                }
            }
        }

    }

    public func forEachPage(
        _ action: @MainActor @escaping (_ page: Page, _ row: UInt32, _ col: UInt32) async -> Void
    ) async {
        var col: UInt32 = 0
        var row: UInt32 = 0
        for rowLine in layout {
            for page in rowLine {
                await action(page, row, col)
                col += 1
            }
            row += 1
            col = 0
        }
    }

    public func renderPages() async {
        if windowTooSmallPage.windowTooSmall() {
            await windowTooSmallPage.render()
            return
        }
        await forEachPage { page, _, _ in
            await page.render()
        }
        await commandPage.render()
    }

    public func resizePages(
        _ newWidth: UInt32,
        _ newHeight: UInt32
    ) async {
        await windowTooSmallPage.onResize(
            newPageState: .init(
                absX: 0,
                absY: 0,
                width: newWidth,
                height: newHeight
            )
        )
        await commandPage.onResize(
            newPageState: .init(
                absX: 0,
                absY: Int32(newHeight) - 2,
                width: newWidth,
                height: 2
            )
        )
        let commandPageHeight: UInt32 = 2
        let availableHeight = newHeight - commandPageHeight

        let numRows = UInt32(layout.count)
        if numRows == 0 {
            return
        }

        let baseRowHeight = availableHeight / numRows
        let extraHeight = availableHeight % numRows

        var currentY: UInt32 = 0

        for (rowIndex, rowLine) in layout.enumerated() {
            let numColumns = UInt32(rowLine.count)
            if numColumns == 0 {
                continue
            }

            let rowHeight =
                baseRowHeight + (UInt32(rowIndex) < extraHeight ? 1 : 0)

            let baseColumnWidth = newWidth / numColumns
            let extraWidth = newWidth % numColumns

            var currentX: UInt32 = 0

            for (colIndex, page) in rowLine.enumerated() {
                let pageWidth =
                    baseColumnWidth + (UInt32(colIndex) < extraWidth ? 1 : 0)

                let newPageState = PageState(
                    absX: Int32(currentX),
                    absY: Int32(currentY),
                    width: pageWidth,
                    height: rowHeight
                )

                await page.onResize(newPageState: newPageState)
                await page.render()

                currentX += pageWidth
            }
            currentY += rowHeight
        }
    }

    public func minimumRequiredDiminsions() async -> (
        minWidth: UInt32,
        minHeight: UInt32
    ) {
        // key: col, val: width
        var minWidthMap: [UInt32: UInt32] = [:]
        // key: row, val: height
        var minHeightMap: [UInt32: UInt32] = [:]

        // Find the maximum width in minimum widths in one column
        // And maximum height in minimum heights in one row
        // If that makes sense...
        await forEachPage { page, row, col in
            let minDim = await page.getMinDimensions()
            if (minWidthMap[col] == nil)
                || (minWidthMap[col] != nil && minWidthMap[col]! < minDim.width)
            {
                minWidthMap[col] = minDim.width
            }
            if (minHeightMap[row] == nil)
                || (minHeightMap[row] != nil && minHeightMap[row]! < minDim.height)
            {
                minHeightMap[row] = minDim.height
            }
        }

        var minWidth: UInt32 = 0
        var minHeight: UInt32 = 0
        for width in minWidthMap.values {
            minWidth += width
        }
        for height in minHeightMap.values {
            minHeight += height
        }
        return (minWidth, minHeight)
    }

}
