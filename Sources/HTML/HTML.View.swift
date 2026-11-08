import CSS
import HTML_Rendering

extension HTML.View {
    public func onclick(_ content: String) -> some HTML.View {
        self.attribute("onclick", content)
    }
}
