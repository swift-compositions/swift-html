#if DOM
    #if arch(wasm32)
        import Executor_Hosted
        @_spi(ExperimentalCustomExecutors) import _Concurrency
    #endif

    extension HTML.DOM {

        public enum Loop {}
    }

    extension HTML.DOM.Loop {

        // WHY: a WebAssembly module in a page runs on the page's one thread; the exported functions and the module's own code are its only callers.
        nonisolated(unsafe) public static var dispatch: (Int32) -> Void = { _ in }

        // WHY: a WebAssembly module in a page runs on the page's one thread; the exported functions and the module's own code are its only callers.
        nonisolated(unsafe) public static var tick: () -> Void = {}
    }

    #if arch(wasm32)
        extension HTML.DOM.Loop {

            // WHY: a WebAssembly module in a page runs on the page's one thread; the exported functions and the module's own code are its only callers.
            nonisolated(unsafe) static var entered = false

            // WHY: a WebAssembly module in a page runs on the page's one thread; the exported functions and the module's own code are its only callers.
            nonisolated(unsafe) static var installed = false

            static func enter(_ body: () -> Void) {
                if unsafe entered {
                    body()
                    return
                }
                if unsafe !installed {
                    unsafe installed = true
                    _createExecutors(factory: HTML.DOM.Loop.Executor.Factory.self)
                }
                unsafe entered = true
                withoutActuallyEscaping(body) { body in
                    // WHY: the job that runs the body is drained before this function returns, on the page's one thread.
                    nonisolated(unsafe) let body = body
                    Task { @MainActor in body() }
                    HTML.DOM.Loop.Executor.shared.drain()
                }
                unsafe entered = false
            }
        }
    #endif
#endif
