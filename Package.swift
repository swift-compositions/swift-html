// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-html",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "HTML", targets: ["HTML"]),
        .library(name: "HTML DOM", targets: ["HTML DOM"]),
    ],
    traits: [
        .trait(
            name: "Translating",
            description: "Include TranslatedString integration for internationalization support"
        ),
        .trait(
            name: "Markdown",
            description: "The Markdown view, which renders Markdown as HTML"
        ),
        .trait(
            name: "DOM",
            description: "HTML DOM, which mounts an HTML view into a browser page"
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-compositions/swift-html-render.git", branch: "main"),
        .package(
            url: "https://github.com/swift-compositions/swift-markdown-html-render.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-compositions/swift-css.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-svg.git", branch: "main"),
        .package(url: "https://github.com/swift-ecma/swift-ecma-262.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-4648.git", branch: "main"),
        .package(url: "https://github.com/swift-whatwg/swift-whatwg-url.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-color.git", branch: "main"),
        .package(
            url: "https://github.com/swift-atoms/swift-byte.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-compositions/swift-translating.git",
            branch: "main",
            traits: [.trait(name: "TranslatingPlatform", condition: .when(traits: ["Translating"]))]
        ),
        .package(url: "https://github.com/swift-atoms/swift-ascii.git", branch: "main", traits: ["Coder", "Parser", "Serializer"]),
        .package(url: "https://github.com/swift-atoms/swift-coder.git", branch: "main", traits: ["Carrier", "Map"]),
        .package(url: "https://github.com/swift-atoms/swift-ratio.git", branch: "main", traits: ["Bit", "Difference", "Ordinal"]),
        .package(url: "https://github.com/swift-atoms/swift-span.git", branch: "main", traits: ["Byte", "Iterator"]),
        .package(url: "https://github.com/swift-atoms/swift-finite.git", branch: "main", traits: ["Tagged"]),
        .package(url: "https://github.com/swift-atoms/swift-memory.git", branch: "main", traits: ["Cursor", "Lock", "Map", "Shared"]),
        .package(url: "https://github.com/swift-atoms/swift-affine.git", branch: "main", traits: ["Tagged", "Vector"]),
        .package(url: "https://github.com/swift-atoms/swift-binary.git", branch: "main", traits: ["Serializer"]),
        .package(url: "https://github.com/swift-atoms/swift-collection.git", branch: "main", traits: ["Repetition", "Search"]),
        .package(url: "https://github.com/swift-atoms/swift-coordinate.git", branch: "main", traits: ["Tagged"]),
        .package(url: "https://github.com/swift-atoms/swift-cyclic.git", branch: "main", traits: ["Index", "Tagged"]),
        .package(url: "https://github.com/swift-atoms/swift-difference.git", branch: "main", traits: ["Tagged"]),
        .package(url: "https://github.com/swift-atoms/swift-displacement.git", branch: "main", traits: ["Tagged"]),
        .package(url: "https://github.com/swift-atoms/swift-formatter.git", branch: "main", traits: ["Conversions", "Number", "Radix", "Tagged"]),
        .package(url: "https://github.com/swift-atoms/swift-geometry.git", branch: "main", traits: ["Affine"]),
        .package(url: "https://github.com/swift-atoms/swift-iterator.git", branch: "main", traits: ["Repetition", "Search"]),
        .package(url: "https://github.com/swift-molecules/swift-memory-allocation.git", branch: "main", traits: ["MemoryAllocatorArena", "MemoryInline", "MemorySmall"]),
        .package(
            url: "https://github.com/swift-atoms/swift-parser.git",
            branch: "main",
            traits: ["Always", "Append", "Choice", "Either", "Iterator", "IteratorLeaves", "Map", "Optic", "Pair", "Predicate", "Product", "Repetition", "Skip"]
        ),
        .package(url: "https://github.com/swift-atoms/swift-point.git", branch: "main", traits: ["Affine", "Tagged"]),
        .package(url: "https://github.com/swift-atoms/swift-predicate.git", branch: "main", traits: ["Always"]),
        .package(url: "https://github.com/swift-atoms/swift-renderer.git", branch: "main", traits: ["Document"]),
        .package(url: "https://github.com/swift-atoms/swift-serializer.git", branch: "main", traits: ["Always", "Byte", "Either", "Map", "Optic", "Pair", "Repetition"]),
        .package(url: "https://github.com/swift-atoms/swift-storage.git", branch: "main", traits: ["Generational", "Memory"]),
        .package(url: "https://github.com/swift-atoms/swift-text.git", branch: "main", traits: ["Byte", "Casing"]),
        .package(url: "https://github.com/swift-atoms/swift-time.git", branch: "main", traits: ["Affine"]),
        .package(url: "https://github.com/swift-atoms/swift-translation.git", branch: "main", traits: ["Affine"]),
        .package(url: "https://github.com/swift-atoms/swift-observer.git", branch: "main", traits: ["Tracking"]),
        .package(url: "https://github.com/swift-whatwg/swift-whatwg-dom.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-sequence.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-optic.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-ordinal.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "HTML",
            dependencies: [
                .product(name: "HTML Rendering", package: "swift-html-render"),
                .product(name: "CSS", package: "swift-css"),
                .product(name: "CSS Theming", package: "swift-css"),
                .product(
                    name: "Markdown HTML Rendering",
                    package: "swift-markdown-html-render",
                    condition: .when(traits: ["Markdown"])
                ),
                .product(name: "Color", package: "swift-color"),
                .product(name: "ECMA 262", package: "swift-ecma-262"),
                .product(name: "RFC 4648", package: "swift-rfc-4648"),
                .product(name: "WHATWG Form URL Encoded", package: "swift-whatwg-url"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "SVG", package: "swift-svg"),
                .product(
                    name: "Translating",
                    package: "swift-translating",
                    condition: .when(traits: ["Translating"])
                ),
                .product(
                    name: "Translating Dependencies",
                    package: "swift-translating",
                    condition: .when(traits: ["Translating"])
                ),
            ],
            swiftSettings: [
                .define("TRANSLATING", .when(traits: ["Translating"]))
            ]
        ),
        .target(
            name: "HTML DOM",
            dependencies: [
                .product(name: "HTML Rendering", package: "swift-html-render"),
                .product(
                    name: "Observer",
                    package: "swift-observer",
                    condition: .when(traits: ["DOM"])
                ),
                .product(
                    name: "WHATWG DOM",
                    package: "swift-whatwg-dom",
                    condition: .when(traits: ["DOM"])
                ),
                .product(
                    name: "Sequence",
                    package: "swift-sequence",
                    condition: .when(traits: ["DOM"])
                ),
                .product(
                    name: "Ordinal",
                    package: "swift-ordinal",
                    condition: .when(traits: ["DOM"])
                ),
            ]
        ),
        .testTarget(
            name: "HTML DOM Tests",
            dependencies: [
                .target(name: "HTML"),
                .target(name: "HTML DOM"),
                .product(
                    name: "WHATWG DOM Test Support",
                    package: "swift-whatwg-dom",
                    condition: .when(traits: ["DOM"])
                ),
                .product(name: "Optic", package: "swift-optic"),
            ]
        ),
        .testTarget(
            name: "HTML Tests",
            dependencies: [
                .target(name: "HTML"),
                .product(name: "HTML Rendering Core Test Support", package: "swift-html-render"),
                .product(name: "RFC 4648", package: "swift-rfc-4648"),
            ],
            path: "Tests/HTML Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
