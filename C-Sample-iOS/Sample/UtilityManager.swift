//
//  UtilityManager.swift
//  Sample
//
//  Created by Deeprajj on 12/02/26.
//

import Foundation
import UIKit

class UtilityManager {

    private static let sdkVersion = "2.0.0"

    static func appVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "iOS-SDK(\(sdkVersion)-AppVersion : \(appVersion))"
        }
        return ""
    }

    static func osVersion() -> String {
        return UIDevice.current.systemVersion
    }

    static func appBuildNumber() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return appVersion
        }
        return ""
    }

    static func generateHashValueFor(input: String) -> String {
        return String(input.hashValue)
    }

    static func getVersionWithBuildNumber() -> String {
        return "Version \(appVersion())"
    }
}
