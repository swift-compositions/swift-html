public import Renderer

extension HTML.DOM.Sink {

    struct Scope {

        let identity: Renderer.Document.Identity

        let depth: Int

        var ordinal: Int
    }
}
