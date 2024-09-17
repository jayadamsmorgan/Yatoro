import Logging
import notcurses

// public struct SearchPage: Page {
//
//     public var plane: Plane
//     public var logger: Logger?
//
//     public init(stdPlane: Plane, logger: Logger?) {
//         guard
//             let plane = Plane(
//                 in: stdPlane,
//                 opts: .init(
//                     x: 0,
//                     y: 0,
//                     width: stdPlane.width,
//                     height: stdPlane.height - 10,
//                     debugID: "SEARCH_PAGE",
//                     flags: [.verticalScrolling]
//                 ),
//                 logger: logger
//             )
//         else {
//             let message = "Unable to create SearchPage"
//             logger?.error(message)
//             fatalError(message)
//         }
//         self.plane = plane
//     }
//
// }
