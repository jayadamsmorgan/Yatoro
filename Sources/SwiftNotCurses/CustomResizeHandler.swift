import Foundation

@MainActor fileprivate var handler: (() async -> Void) = {}

@_cdecl("sigwinch_handler")
private func sigwinch_handler(_ signal: Int32) -> Void {
    Task { @MainActor in
        await handler()
    }
}

@MainActor
public func setupSigwinchHandler(onResize: @escaping @MainActor () async -> Void) {
    handler = onResize
    var action = sigaction()
    action.__sigaction_u = unsafeBitCast(
        sigwinch_handler as @convention(c) (Int32) -> Void,
        to: __sigaction_u.self
    )
    action.sa_flags = 0
    sigemptyset(&action.sa_mask)

    if sigaction(SIGWINCH, &action, nil) != 0 {
        perror("sigaction")
        exit(1)
    }
}
