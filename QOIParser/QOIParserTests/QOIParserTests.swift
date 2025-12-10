//
//  QOIParserTests.swift
//  QOIParserTests
//
//  Created by Klajd Deda on 12/7/25.
//

import Testing
import Foundation
import BinaryParsing
import IDDSwift
import Log4swift
@testable import QOIParser

struct QOIParserTests {
    @Test func parseAntelope() throws {
        Log4swift.configure(fileLogConfig: .none)

        do {
            let rootFilePath = URL.init(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            let url = rootFilePath.appendingPathComponent("Images/antelope.qoi")
            Log4swift[Self.self].info("loading: '\(url.path)'")

            let data = try Data(contentsOf: url)
            // let data = try Data(contentsOf: URL.home.appendingPathComponent("Desktop/tricolor.qoi"))

            Log4swift[Self.self].info(" loaded: '\(data.count.decimalFormatted) bytes'")
            let parser: QOI = try data.withParserSpan { buffer in
                let rv = try QOI(parsing: &buffer)

                Log4swift[Self.self].info("rv: '\(rv) bytes'")
                return rv
            }
            Log4swift[Self.self].info("decoded: 'parser[width: \(parser.width), height: \(parser.height)] from: '\(parser.pixels.count.decimalFormatted) bytes'")
            // if let cgImage = parser.toCGImage {
            //  Log4swift[Self.self].info("created: 'cgImage[width: \(cgImage.width), height: \(cgImage.height)] from: '\(parser.pixels.count.decimalFormatted) bytes'")
            // }
        } catch {
            Log4swift[Self.self].error("error: '\(error)'")
        }
    }
}
