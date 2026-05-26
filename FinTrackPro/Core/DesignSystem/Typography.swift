import SwiftUI

enum FTTypo {
    static let syne     = "Syne"
    static let jakarta  = "PlusJakartaSans"
    static let firaCode = "FiraCode"

    static func hero()     -> Font { .custom(syne,     size: 40, relativeTo: .largeTitle).weight(.heavy) }
    static func h1()       -> Font { .custom(syne,     size: 32, relativeTo: .title).weight(.bold) }
    static func h2()       -> Font { .custom(syne,     size: 22, relativeTo: .title2).weight(.semibold) }
    static func body()     -> Font { .custom(jakarta,  size: 15, relativeTo: .body).weight(.regular) }
    static func bodySemi() -> Font { .custom(jakarta,  size: 15, relativeTo: .body).weight(.semibold) }
    static func caption()  -> Font { .custom(jakarta,  size: 12, relativeTo: .caption).weight(.medium) }
    static func data()     -> Font { .custom(firaCode, size: 13, relativeTo: .callout).weight(.regular) }
    static func amount()   -> Font { .custom(firaCode, size: 32, relativeTo: .title).weight(.medium) }
    static func amountLg() -> Font { .custom(firaCode, size: 48, relativeTo: .largeTitle).weight(.medium) }
    static func label()    -> Font { .custom(firaCode, size: 10, relativeTo: .caption2).weight(.regular) }
}
