public import Renderer

extension HTML.DOM.Sink {

    struct Pending {

        var attributes: [(name: String, value: String)]

        var listeners: [Renderer.Document.Listener]

        init() {
            self.attributes = []
            self.listeners = []
        }
    }
}
