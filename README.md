# swift-html

Use this package when you build HTML pages in Swift and want elements, CSS styling, colors and SVG behind one import. Start from `HTML.Document`, and write elements with the lowercase names, such as `div` for `HTML.ContentDivision.Element`. If you only need to render HTML views without CSS or SVG, use swift-html-render. If you only need SVG, use swift-svg.

## Laws

- `InlineSVG` writes its SVG markup into the page as is, not escaped. `svg(_:)` does the same with a string and does not check that it is SVG.
- `HTML.Image.Element.init(svg:alt:base64:loading:)` puts the SVG in a data URI. By default it is base64 encoded, so no markup appears in the page. With `base64` false it is percent-encoded as UTF-8, with spaces as %20. Loading defaults to eager.
- `DarkModeColor.readablePrimaryColor(on:)` looks only at the background's light variant. It returns black when the background's brightness, weighted 299, 587 and 114 for red, green and blue, is above half, and white otherwise. A background that can't be read as sRGB gets black.
- `DarkModeColor.gradientMidpoint(from:to:)` averages the sRGB channels of the light variants and of the dark variants separately. It is nil if any of the four colors can't be read as sRGB.
- `HTML.View.gradient(bottom:top:)` runs from bottom to top, with the light colors as an inline style and the dark colors in dark mode. The three-color form puts the middle color at 50%.
- Interpolating a view with `html:` in a string renders it and wraps it in backticks as a JavaScript template literal. Backslashes, backticks, `${`, U+2028 and U+2029 are escaped. Nothing else is.
