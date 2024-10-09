import SwiftNotCurses

extension UIOptions {

    public init(
        logLevel: UILogLevel = .silent,
        config: Config.UIConfig,
        flags: [UIOptionFlag] = UIOptionFlag.cliMode()
    ) {
        let margins = config.margins
        let leftMargin = margins.left ?? margins.all
        let rightMargin = margins.right ?? margins.all
        let bottomMargin = margins.bottom ?? margins.all
        let topMargin = margins.top ?? margins.all
        self.init(
            logLevel: logLevel,
            leftMargin: leftMargin,
            rightMargin: rightMargin,
            bottomMargin: bottomMargin,
            topMargin: topMargin,
            flags: flags
        )
    }
}
