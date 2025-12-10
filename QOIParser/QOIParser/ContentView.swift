//
//  ContentView.swift
//  QOIParser
//
//  Created by Klajd Deda on 12/7/25.
//

import SwiftUI
import IDDSwift
import Log4swift
import BinaryParsing

struct ContentView: View {
    @State var image: NSImage? = .none

    func loadData() {
        do {
            let rootFilePath = URL.init(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            let url = rootFilePath.appendingPathComponent("Images/antelope.qoi")
            let data = try Data(contentsOf: url)

            Log4swift[Self.self].info(" loaded: '\(data.count.decimalFormatted) bytes'")
            let parser: QOI = try data.withParserSpan { buffer in
                let rv = try QOI(parsing: &buffer)

                Log4swift[Self.self].info("rv: '\(rv) bytes'")
                return rv
            }
            Log4swift[Self.self].info("decoded: '\(parser.pixels.count.decimalFormatted) bytes'")

            if let cgImage = parser.toCGImage {
                self.image = NSImage(
                    cgImage: cgImage,
                    size: .init(width: parser.width, height: parser.height)
                )
                Log4swift[Self.self].info("created: 'image with \(parser.pixels.count.decimalFormatted) bytes'")
            }
        } catch {
            Log4swift[Self.self].error("error: '\(error)'")
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            Divider()
            HStack {
                Spacer()
                Button(action: {
                    loadData()
                }, label: {
                    Image(systemName: "document.circle")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Load")
                })
            }
            Divider()
            HStack {
                Spacer()
                if let image = self.image {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 480, height: 320)
                } else {
                    Text("No data")
                }
                Spacer()
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .frame(width: 480 + 100, height: 320 + 120)
}
