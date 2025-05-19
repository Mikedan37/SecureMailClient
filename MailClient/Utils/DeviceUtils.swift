//  DeviceUtils.swift
//  MailClient
//  Created by Michael Danylchuk on 5/12/25.

// DeviceUtils.swift
import Foundation

#if os(iOS)
import UIKit
enum DeviceUtils {
    static var deviceID: String {
        UIDevice.current.name
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()
    }
}
#elseif os(macOS)
enum DeviceUtils {
    static var deviceID: String {
        (Host.current().localizedName ?? "mac")
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()
    }
}
#else
enum DeviceUtils {
    static var deviceID: String {
        "unknown-device"
    }
}
#endif
