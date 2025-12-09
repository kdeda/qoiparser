//
//  QOIParserTests.swift
//  QOIParserTests
//
//  Created by Klajd Deda on 12/7/25.
//

import Testing
import Foundation
//import CoreGraphics
import BinaryParsing
import IDDSwift
import Log4swift
@testable import QOIParser

//extension QOI {
//    /// Parses an image from the given QOI data.
//    func parseQOI(from input: inout Data) -> QOI? {
//        guard let header = QOI.Header(parsing: &input) else { return nil }
//
//        let pixels = readEncodedPixels(from: &input)
//            .flatMap { decodePixels(from: $0) }
//            .prefix(header.pixelCount)
//            .flatMap { $0.data(channels: header.channels) }
//
//        return QOI(width: 1833, height: 1222, channels: .rgb, colorSpace: .sRGBLinearAlpha, data: pixels)
//    }
//}

struct QOIParserTests {
    @Test func parseAntelope() throws {
        Log4swift.configure(fileLogConfig: .none)

        do {
            let rootFilePath = URL.init(fileURLWithPath: #filePath).deletingLastPathComponent()
            let url = rootFilePath.deletingLastPathComponent().appendingPathComponent("Images/antelope.qoi")
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

    struct BzDoneLine {
        static let columnWidth = [1, 1, 3, 14, 83, 3, 16, 9, 40, 16, 16]
        static let dash_: Character = "-"
        static let dash = dash_.asciiValue!
        static let tab_: Character = "\t"
        static let tab = tab_.asciiValue!

        let columns: [ArraySlice<UInt8>]
        //        let columns1: ArraySlice<UInt8>
        //        let columns2: ArraySlice<UInt8>
        //        let columns3: ArraySlice<UInt8>
        //        let columns4: ArraySlice<UInt8>
        //        let columns5: ArraySlice<UInt8>
        //        let columns6: ArraySlice<UInt8>
        //        let columns7: ArraySlice<UInt8>
        //        let columns8: ArraySlice<UInt8>
        //        let columns9: ArraySlice<UInt8>
        //        let columns10: ArraySlice<UInt8>
        //        let columns11: ArraySlice<UInt8>
        //        let columns12: ArraySlice<UInt8>
        //        let columns13: ArraySlice<UInt8>
        private let filePath_: ArraySlice<UInt8>
        var filePath: String {
            String(decoding: filePath_, as: UTF8.self)
        }

        init(row: ArraySlice<UInt8>) {
            var columns = [ArraySlice<UInt8>]()

            // TODO: try this with the inline array, macos 26
            columns.reserveCapacity(13)
            //  let rowString = try? (row + [0]).withParserSpan { span in
            //      let rv = try? String(parsingNulTerminated: &span)
            //
            //      // Log4swift[Self.self].error("rowString: '\(rv)'")
            //      return rv
            //  }
            //  let rowString_ = String(decoding: row, as: UTF8.self)
            //  Log4swift[Self.self].error("rowString: '\(rowString_)'")

            var begin = row.startIndex
            //  row.withParserSpan { span in
            //      let parsedArray = Array(parsingRemainingBytes: &span)
            //      Log4swift[Self.self].error("rowString: '\(parsedArray)'")
            //  }

            BzDoneLine.columnWidth.forEach { length in
                columns.append(row[begin ..< (begin + length)])
                begin += length
                begin += 1
            }

            if row[begin] == BzDoneLine.dash {
                begin += 1
                columns.append([])
            } else {
                columns.append(row[begin ..< begin + 18])
                begin += 18
            }
            begin += 1

            // chunkid
            var length = 0
            while true {
                if row[begin + length] == BzDoneLine.tab {
                    break
                } else {
                    length += 1
                }
            }

            // file size
            columns.append(row[begin ..< begin + length])
            begin += length
            begin += 1

            self.columns = columns
            self.filePath_ = row.suffix(from: begin)
        }

        var description: String {
            "'" + columns.map({ String(decoding: $0, as: UTF8.self) }).joined(separator: "' | '") + "'"
        }
    }

    private func parseBzDoneFile(_ fileURL: URL) async {
        await withTaskGroup(of: Void.self) { group  in
            /// run the process in a task, when it completes we will finish the continuation
            group.addTask {
                guard let stream = try? fileURL.readLines()
                else { return }

                var total = 0
                for await rows in stream {
                    // comment it out to see time spent on the `fileURL.readLines()`
                    // well close to 4 seconds for a 4.1 GB file
                    // cat file | wc on terminal takes 8.5 seconds
                    let lines = rows.map { BzDoneLine.init(row: $0) }
                    total += lines.count
                    // total += rows.count
                    Log4swift[Self.self].info("rows: '\(rows.count.decimalFormatted.leftPadding(to: 6))' total: '\(total.decimalFormatted.leftPadding(to: 12))'")
                }

                Log4swift[Self.self].info("completed")
            }
        }
    }

    /**
     cd /Library/Backblaze.bzpkg/bzdata/bzbackup/bzdatacenter
     ```
     cat bz_done_20250901_0.dat | awk -F"\t" '{ printf("\"%s\" | \"%s\" | \"%s\" | \"%s\" | \"%s\" | \"%s\" | \"%s\" | \"%s\" | \"%s\" | \"%s\" | \"%s\" | \"%s\"\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) }'
     ```
     */
    @Test func parseBzDone() async throws {
        Log4swift.configure(fileLogConfig: .none)

        let fileURL = URL.init(fileURLWithPath: "/Library/Backblaze.bzpkg/bzdata/bzbackup/bzdatacenter/bz_done_20251117_0.dat")
        await parseBzDoneFile(fileURL)
    }

    /**
     cd /Library/Backblaze.bzpkg/bzdata/bzbackup/bzdatacenter
     ```
     find . -name "bz_done*.dat" -exec cat {} \; > /tmp/all.dat
     tail -1000000 /tmp/all.dat > /tmp/all_1_000_000.dat
     tail -2000000 /tmp/all.dat > /tmp/all_2_000_000.dat
     tail -10000000 /tmp/all.dat > /tmp/all_10_000_000.dat
     ```
     */
    @Test func parseAllBzDones() async throws {
        // Log4swift.configure(fileLogConfig: .none)
        let logRootURL = URL.home.appendingPathComponent("Library/Logs/QOIParserApp")
        // Log4swift.configureCompactSettings()
        Log4swift.configure(fileLogConfig: try? .init(logRootURL: logRootURL, appPrefix: "QOIParserApp", appSuffix: "", daysToKeep: 30))

//        let fileURL = URL.init(fileURLWithPath: "/tmp/all_1_000_000.dat")
//        let fileURL = URL.init(fileURLWithPath: "/tmp/all_10_000_000.dat")
        let fileURL = URL.init(fileURLWithPath: "/tmp/all.dat")
        await parseBzDoneFile(fileURL)
    }
}
