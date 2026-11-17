#if DOM
    import Ordinal
    public import Renderer
    public import Renderer_Document

    extension HTML.DOM.Sink {

        struct Scope {

            let identity: Renderer.Document.Identity

            let depth: Int

            var ordinal: Ordinal
        }
    }
#endif
