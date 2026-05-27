import SwiftUI

enum FTColors {
    static let background    = Color(hex: 0x030B14)
    static let surface       = Color(hex: 0x071525)
    static let card          = Color(hex: 0x0C1F34)
    static let elevated      = Color(hex: 0x152A42)

    static let positive      = Color(hex: 0x00D68F)
    static let negative      = Color(hex: 0xFF4B6E)
    static let warning       = Color(hex: 0xF0A500)
    static let accent        = Color(hex: 0x1AAFBF)

    static let textPrimary   = Color(hex: 0xEEF2F7)
    static let textSecondary = Color(hex: 0x8FA3BF)
    static let textDisabled  = Color(hex: 0x4A6080)
    static let border        = Color(hex: 0x152A42)
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red:     Double((hex >> 16) & 0xff) / 255,
            green:   Double((hex >> 08) & 0xff) / 255,
            blue:    Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }

    init?(hexString: String?) {
        guard let raw = hexString else { return nil }
        let hex = raw.hasPrefix("#") ? String(raw.dropFirst()) : raw
        guard hex.count == 6, let value = UInt(hex, radix: 16) else { return nil }
        self.init(hex: value)
    }
}
