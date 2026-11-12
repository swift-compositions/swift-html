#if DOM
    #if arch(wasm32)
        @_spi(ExperimentalCustomExecutors) import _Concurrency

        extension HTML.DOM.Loop.Executor {

            struct Factory {}
        }

        extension HTML.DOM.Loop.Executor.Factory: ExecutorFactory {

            static var mainExecutor: any MainExecutor {
                HTML.DOM.Loop.Executor.shared
            }

            static var defaultExecutor: any TaskExecutor {
                HTML.DOM.Loop.Executor.shared
            }
        }
    #endif
#endif
