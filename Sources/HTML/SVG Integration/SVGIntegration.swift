import Byte
import RFC_4648
import SVG
import SVG_Rendering
import SVG_Standard
import WHATWG_Form_URL_Encoded
import WHATWG_HTML_Elements
import WHATWG_HTML_MediaAttributes

public struct InlineSVG: HTML.View {

    private let content: SVG.AnyView

    public init<Content: SVG.View>(@SVG.Builder _ content: () -> Content) {
        self.content = SVG.AnyView(content())
    }

    public init<Content: SVG.View>(_ content: Content) {
        self.content = SVG.AnyView(content)
    }
}

extension InlineSVG {

    public var body: some HTML.View {
        HTML.Raw([Byte](content))
    }
}

public func svg(_ svgString: String) -> some HTML.View {
    HTML.Raw(svgString)
}

extension HTML.Image.Element {
    public init<Content: SVG.View>(
        svg: Content,
        alt: HTML.Alt.Attribute?,
        base64: Bool = true,
        loading: HTML.Loading.Attribute? = .eager
    ) {
        var src: HTML.Src.Attribute {
            guard base64 else {

                return
                    "data:image/svg+xml;charset=utf-8,\(WHATWG_Form_URL_Encoded.PercentEncoding.encode(String(svg), space: .percentEscaped))"
            }
            return "data:image/svg+xml;base64,\([Byte](svg).base64.encoded())"
        }

        self = .init(
            src: src,
            alt: alt,
            loading: loading
        )
    }
}
