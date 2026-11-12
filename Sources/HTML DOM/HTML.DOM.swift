#if DOM
    public import HTML_Rendering

    extension HTML {
        public enum DOM {}
    }

    extension HTML.DOM {

        @discardableResult
        public static func mount<Content: HTML.View>(
            in selector: String,
            host: HTML.DOM.Host,
            @HTML.Builder _ content: @escaping () -> Content
        ) -> HTML.DOM.Mount {
            let mount = install(in: selector, host: host, content)
            mount.update()
            return mount
        }

        static func install<Content: HTML.View>(
            in selector: String,
            host: HTML.DOM.Host,
            _ content: @escaping () -> Content
        ) -> HTML.DOM.Mount {
            let mount = HTML.DOM.Mount(selector: selector, host: host) { context in
                context.render(content())
            }
            unsafe HTML.DOM.Runtime.shared.install(mount)
            return mount
        }
    }

    #if arch(wasm32)
        extension HTML.DOM {

            @discardableResult
            public static func mount<Content: HTML.View>(
                in selector: String,
                @HTML.Builder _ content: @escaping () -> Content
            ) -> HTML.DOM.Mount {
                let mount = install(in: selector, host: .browser, content)
                HTML.DOM.Loop.enter { mount.update() }
                return mount
            }
        }
    #endif
#endif
