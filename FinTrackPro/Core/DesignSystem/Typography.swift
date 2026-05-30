import SwiftUI

enum FTTypo {
    private static let syneExtraBold    = "Syne-ExtraBold"
    private static let syneBold         = "Syne-Bold"
    private static let syneSemiBold     = "Syne-SemiBold"
    private static let jakartaRegular   = "PlusJakartaSans-Regular"
    private static let jakartaSemiBold  = "PlusJakartaSans-SemiBold"
    private static let jakartaMedium    = "PlusJakartaSans-Medium"
    private static let firaRegular      = "FiraCode-Regular"
    private static let firaMedium       = "FiraCode-Medium"

    static func hero()     -> Font { .custom(syneExtraBold,   size: 40, relativeTo: .largeTitle) }
    static func h1()       -> Font { .custom(syneBold,        size: 32, relativeTo: .title) }
    static func h2()       -> Font { .custom(syneSemiBold,    size: 22, relativeTo: .title2) }
    static func body()     -> Font { .custom(jakartaRegular,  size: 15, relativeTo: .body) }
    static func bodySemi() -> Font { .custom(jakartaSemiBold, size: 15, relativeTo: .body) }
    static func caption()  -> Font { .custom(jakartaMedium,   size: 12, relativeTo: .caption) }
    static func data()     -> Font { .custom(firaRegular,     size: 13, relativeTo: .callout) }
    static func amount()   -> Font { .custom(firaMedium,      size: 32, relativeTo: .title) }
    static func amountLg() -> Font { .custom(firaMedium,      size: 48, relativeTo: .largeTitle) }
    static func label()    -> Font { .custom(firaRegular,     size: 10, relativeTo: .caption2) }
}
