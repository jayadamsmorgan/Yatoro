import Foundation

@MainActor fileprivate var _sigwinch_handler: (() async -> Void) = {}
@MainActor fileprivate var _sigint_handler: (() async -> Void) = {}

@_cdecl("sigwinch_handler")
private func sigwinch_handler(_ signal: Int32) -> Void {
    Task { @MainActor in
        await _sigwinch_handler()
    }
}

@_cdecl("sigint_handler")
private func sigint_handler(_ signal: Int32) -> Void {
    Task { @MainActor in
        await _sigint_handler()
    }
}

@MainActor
public func setupSigwinchHandler(onResize: @escaping @MainActor () async -> Void) {
    _sigwinch_handler = onResize
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

@MainActor
public func setupSigintHandler(onStop: @escaping @MainActor () async -> Void) {
    _sigint_handler = onStop
    var action = sigaction()
    action.__sigaction_u = unsafeBitCast(
        sigint_handler as @convention(c) (Int32) -> Void,
        to: __sigaction_u.self
    )
    action.sa_flags = 0
    sigemptyset(&action.sa_mask)

    if sigaction(SIGINT, &action, nil) != 0 {
        perror("sigaction")
        exit(1)
    }
}
