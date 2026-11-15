#if DOM
    extension HTML.DOM.Runtime {

        public var elapsed: Duration {
            host.elapsed()
        }

        public var scheduled: Int { timers.count }

        public func after(_ delay: Duration, _ body: @escaping () -> Void) {
            let token = self.token
            self.token &+= 1
            timers[token] = body
            host.timer(delay, token)
        }

        public func fire(_ token: Int32) {
            timers.removeValue(forKey: token)?()
        }

        var host: HTML.DOM.Host {
            if let mount = mounts.last { return mount.host }
            #if arch(wasm32)
                return HTML.DOM.Host.browser
            #else
                return HTML.DOM.Host(flush: { _ in }, schedule: {}, target: { HTML.DOM.Target() })
            #endif
        }
    }
#endif
