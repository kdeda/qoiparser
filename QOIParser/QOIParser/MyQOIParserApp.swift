//
//  QOIParserApp.swift
//  QOIParser
//
//  Created by Klajd Deda on 12/7/25.
//

import SwiftUI
import IDDSwift
import Log4swift

/**
 https://www.c-sharpcorner.com/news/swifts-new-features-unveiled-what-developers-need-to-know

 https://github.com/apple/swift-binary-parsing/blob/main/Examples/QOIParser/QOI.swift
 */
@main
struct QOIParserApp: App {
    init() {
        let logRootURL = URL.home.appendingPathComponent("Library/Logs/QOIParserApp")
        // Log4swift.configureCompactSettings()
        Log4swift.configure(fileLogConfig: try? .init(logRootURL: logRootURL, appPrefix: "QOIParserApp", appSuffix: "", daysToKeep: 30))

        Log4swift[""].info("")
        Log4swift[""].dash("\(Bundle.main.appVersion.shortDescription)")
        Log4swift[""].info("\(Bundle.main.appVersion.shortDescription)")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
