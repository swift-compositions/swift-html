#if DOM
    #if arch(wasm32)
        import Executor_Hosted
        import Executor_Primitive
        @_spi(ExperimentalCustomExecutors) import _Concurrency

        extension HTML.DOM.Loop {

            // WHY: the page's one thread is the only caller; the base class is unchecked Sendable for the same reason.
            final class Executor: Executor_Primitive::Executor.Hosted, @unchecked Sendable {}
        }

        extension HTML.DOM.Loop.Executor: MainExecutor {

            func run() {
                drain()
            }

            func stop() {}
        }

        extension HTML.DOM.Loop.Executor {

            static let shared = HTML.DOM.Loop.Executor(
                wake: {
                    if unsafe !HTML.DOM.Loop.entered { HTML.DOM.Host.browser.schedule() }
                }
            )
        }
    #endif
#endif
