import CSS
import CSS_Standard

@available(*, deprecated, renamed: "DarkModeColor")
public typealias HTMLColor = DarkModeColor

extension DarkModeColor {
    private typealias sRGB = IEC_61966.`2`.`1`.SRGB

    public static func gradientMidpoint(
        from color1: DarkModeColor,
        to color2: DarkModeColor
    ) -> DarkModeColor? {
        func midpoint(
            _ c1: CSS_Standard::Color.Value,
            _ c2: CSS_Standard::Color.Value
        ) -> CSS_Standard::Color.Value? {
            guard let srgb1 = sRGB(c1), let srgb2 = sRGB(c2) else { return nil }

            let midR = (srgb1.r255 + srgb2.r255) / 2
            let midG = (srgb1.g255 + srgb2.g255) / 2
            let midB = (srgb1.b255 + srgb2.b255) / 2

            return .rgb(red: midR, green: midG, blue: midB)
        }

        let lightMid = midpoint(color1.light, color2.light)
        let darkMid = midpoint(color1.dark, color2.dark)

        guard let light = lightMid, let dark = darkMid else { return nil }
        return DarkModeColor(light: light, dark: dark)
    }

    public static func readablePrimaryColor(on backgroundColor: DarkModeColor) -> Self {
        guard let srgb = sRGB(backgroundColor.light) else {
            return .init(.hex("000000"))
        }

        let brightness =
            (Double(srgb.r255) * 299 + Double(srgb.g255) * 587 + Double(srgb.b255) * 114) / 255000
        let color: CSS_Standard::Color.Value = brightness > 0.5 ? .hex("000000") : .hex("FFFFFF")
        return .init(color)
    }
}

extension HTML.View {

    public func gradient(
        bottom: DarkModeColor,
        top: DarkModeColor
    ) -> some HTML.View {
        self
            .css
            .inlineStyle(
                "background",
                "linear-gradient(0deg, \(bottom.light.description) 0%, \(top.light.description) 100%);"
            )
            .dark {
                $0.inlineStyle(
                    "background",
                    "linear-gradient(0deg, \(bottom.dark.description) 0%, \(top.dark.description) 100%);"
                )
            }
    }

    public func gradient(
        bottom: DarkModeColor,
        middle: DarkModeColor,
        top: DarkModeColor
    ) -> some HTML.View {
        self
            .css
            .inlineStyle(
                "background",
                "linear-gradient(0deg, \(bottom.light.description) 0%, \(middle.light.description) 50%, \(top.light.description) 100%);"
            )
            .dark {
                $0.inlineStyle(
                    "background",
                    "linear-gradient(0deg, \(bottom.dark.description) 0%, \(middle.dark.description) 50%, \(top.dark.description) 100%);"
                )
            }
    }
}
