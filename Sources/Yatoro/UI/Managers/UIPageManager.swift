import SwiftNotCurses

@MainActor
public struct UIPageManager {

    var layoutRows: UInt32  // From left to right
    var layoutColumns: UInt32  // From top to bottom

    // Basically an array of rows
    var layout: [[Page]]

    var commandPage: CommandPage
    var windowTooSmallPage: WindowTooSmallPage

    public init?(
        uiConfig: Config.UIConfig,
        stdPlane: Plane
    ) async {
        self.layout = []
        let layoutConfig = uiConfig.layout
        self.layoutRows = layoutConfig.rows
        self.layoutColumns = layoutConfig.cols
        for _ in 0..<layoutColumns {
            layout.append([])
        }

        var index = 0
        for i in 0..<Int(layoutColumns) {
            for _ in 0..<Int(layoutRows) {

                if index == layoutConfig.pages.count {
                    continue
                }

                let pageType = layoutConfig.pages[index]

                index += 1

                switch pageType {

                case .nowPlaying:
                    guard
                        let nowPlayingPage = NowPlayingPage(
                            stdPlane: stdPlane,
                            uiConfig: uiConfig,
                            state: PageState(
                                absX: 0,
                                absY: 0,
                                width: 28,
                                height: 13
                            )
                        )
                    else {
                        logger?.critical("Failed to initiate Player Page.")
                        return nil
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
                            ),
                            colorConfig: uiConfig.colors.queue
                        )
                    else {
                        logger?.critical("Failed to initiate Queue Page.")
                        return nil
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
                            ),
                            colorConfig: uiConfig.colors.search
                        )
                    else {
                        logger?.critical("Failed to initiate Search Page.")
                        return nil
                    }
                    layout[i].append(searchPage)

                }
            }
        }
        guard
            let commandPage = CommandPage(
                stdPlane: stdPlane,
                colorConfig: uiConfig.colors.commandLine
            )
        else {
            fatalError("Failed to initiate Command Page.")
        }

        guard
            let windowTooSmallPage = WindowTooSmallPage(
                stdPlane: stdPlane
            )
        else {
            fatalError("Failed to initiate Window Too Small Page.")
        }
        self.commandPage = commandPage
        self.windowTooSmallPage = windowTooSmallPage
        await setMinimumRequiredDiminsions()
        return
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
        let commandPageHeight: UInt32 = 2
        let availableHeight = newHeight - commandPageHeight

        let numColumns = UInt32(layout.count)
        if numColumns == 0 {
            return
        }

        let baseColumnWidth = newWidth / numColumns
        let extraWidth = newWidth % numColumns

        var currentX: UInt32 = 0

        for (colIndex, colLine) in layout.enumerated() {
            let columnWidth = baseColumnWidth + (UInt32(colIndex) < extraWidth ? 1 : 0)

            let numRows = UInt32(colLine.count)
            if numRows == 0 {
                continue
            }

            let baseRowHeight = availableHeight / numRows
            let extraHeight = availableHeight % numRows

            var currentY: UInt32 = 0

            for (rowIndex, page) in colLine.enumerated() {
                let pageHeight = baseRowHeight + (UInt32(rowIndex) < extraHeight ? 1 : 0)

                let newPageState = PageState(
                    absX: Int32(currentX),
                    absY: Int32(currentY),
                    width: columnWidth,
                    height: pageHeight
                )

                await page.onResize(newPageState: newPageState)
                await page.render()

                currentY += pageHeight
            }
            currentX += columnWidth
        }
        await commandPage.onResize(
            newPageState: .init(
                absX: 0,
                absY: Int32(newHeight) - 2,
                width: newWidth,
                height: 2
            )
        )
        await windowTooSmallPage.onResize(
            newPageState: .init(
                absX: 0,
                absY: 0,
                width: newWidth,
                height: newHeight
            )
        )
    }
    private func setMinimumRequiredDiminsions() async {
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
        await windowTooSmallPage.setMinRequiredDim((minWidth, minHeight))
    }

}
