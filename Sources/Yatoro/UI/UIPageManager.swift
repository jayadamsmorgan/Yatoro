public struct UIPageManager {

    var layoutRows: UInt32  // From left to right
    var layoutColumns: UInt32  // From top to bottom

    // Basically an array of rows
    var layout: [[Page]]

    var commandPage: CommandPage
    var windowTooSmallPage: WindowTooSmallPage

    public init(
        layoutRows: UInt32,
        layoutColumns: UInt32,
        commandPage: CommandPage,
        windowTooSmallPage: WindowTooSmallPage
    ) {
        self.commandPage = commandPage
        self.windowTooSmallPage = windowTooSmallPage
        self.layout = [[]]
        self.layoutRows = layoutRows
        self.layoutColumns = layoutColumns
    }

    public func forEachPage(
        _ action: @escaping (_ page: Page, _ row: UInt32, _ col: UInt32) async
            -> Void
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
        if await windowTooSmallPage.windowTooSmall() {
            await windowTooSmallPage.render()
            return
        }
        await forEachPage { page, _, _ in
            Task { await page.render() }
        }
        Task {
            await commandPage.render()
        }
    }

    public func resizePages(_ newWidth: UInt32, _ newHeight: UInt32) async {
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

                currentX += pageWidth
            }
            currentY += rowHeight
        }
    }

    public func minimumRequiredDiminsions() async -> (
        minWidth: UInt32, minHeight: UInt32
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
            if minWidthMap[col] == nil
                || (minWidthMap[col] != nil
                    && minWidthMap[col]! < minDim.width)
            {
                minWidthMap[col] = minDim.width
            }
            if minHeightMap[row] == nil
                || (minHeightMap[row] != nil
                    && minHeightMap[row]! < minDim.height)
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