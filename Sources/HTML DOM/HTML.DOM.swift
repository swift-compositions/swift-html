public import WHATWG_DOM
public import WHATWG_HTML_Shared

extension HTML {
    public enum DOM {}
}

extension HTML.DOM {

    @discardableResult
    public static func mount<Content: HTML.View>(
        in selector: String,
        host: WHATWG.DOM.Host,
        @HTML.Builder _ content: @escaping () -> Content
    ) -> HTML.DOM.Mount {
        let mount = HTML.DOM.Mount(selector: selector, host: host) { context in
            context.render(content())
        }
        unsafe HTML.DOM.Runtime.shared.install(mount)
        mount.update()
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
            mount(in: selector, host: .browser, content)
        }
    }
#endif
