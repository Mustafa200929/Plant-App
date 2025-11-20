//
//  Extensions.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on 15/11/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .uppercased()

        // Support short forms like RGB (3), RGBA (4) by expanding them (e.g. "FAB" -> "FFAABB")
        if hexString.count == 3 || hexString.count == 4 {
            let chars = Array(hexString)
            hexString = chars.map { "\($0)\($0)" }.joined()
        }

        // Valid lengths are 6 (RRGGBB) or 8 (RRGGBBAA)
        guard hexString.count == 6 || hexString.count == 8 else {
            self = .white
            return
        }

        var rgba: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&rgba) else {
            self = .white
            return
        }

        let hasAlpha = (hexString.count == 8)

        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        let a: CGFloat

        if hasAlpha {
            r = CGFloat((rgba & 0xFF00_0000) >> 24)
            g = CGFloat((rgba & 0x00FF_0000) >> 16)
            b = CGFloat((rgba & 0x0000_FF00) >> 8)
            a = CGFloat(rgba & 0x0000_00FF)
        } else {
            r = CGFloat((rgba & 0xFF00_00) >> 16)
            g = CGFloat((rgba & 0x00FF_00) >> 8)
            b = CGFloat(rgba & 0x0000_FF)
            a = 255.0
        }

        self = Color(.sRGB,
                     red: r / 255.0,
                     green: g / 255.0,
                     blue: b / 255.0,
                     opacity: a / 255.0)
    }
}
