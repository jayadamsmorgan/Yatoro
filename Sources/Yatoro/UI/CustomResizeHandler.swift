import Foundation

var resizeOccurred: sig_atomic_t = 0

@_cdecl("sigwinch_handler")
func sigwinch_handler(_ signal: Int32) -> Void {
    // Set the flag
    resizeOccurred = 1
}
func setupSigwinchHandler() {
    var action = sigaction()
    action.__sigaction_u = unsafeBitCast(sigwinch_handler as @convention(c) (Int32) -> Void, to: __sigaction_u.self)
    action.sa_flags = 0
    sigemptyset(&action.sa_mask)

    if sigaction(SIGWINCH, &action, nil) != 0 {
        perror("sigaction")
        exit(1)
    }
}
