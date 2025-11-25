//
//  devicecheckerfortips.swift
//  Challenge 3
//
//  Created by Adhavan senthil kumar on 25/11/25.
//

import Foundation
func isCompatibleDevice() -> Bool {
    var systemInfo = utsname()
    uname(&systemInfo)

    let model = withUnsafePointer(to: &systemInfo.machine) { ptr in
        String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
    }

    let majorString = model
        .replacingOccurrences(of: "iPhone", with: "")
        .split(separator: ",")
        .first ?? "0"

    let major = Int(majorString) ?? 0

    return major >= 16
}
