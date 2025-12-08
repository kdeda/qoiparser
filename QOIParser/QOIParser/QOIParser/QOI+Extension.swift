//
//  QOI+Extension.swift
//  QOIParser
//
//  Created by Klajd Deda on 12/8/25.
//

import CoreGraphics

extension QOI {
    /// Converts QOI pixel data to a CGImage
    var toCGImage: CGImage? {
        let bytesPerPixel = Int(channels.rawValue)
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        let bitsPerPixel = bytesPerPixel * bitsPerComponent

        // Determine color space and bitmap info based on channels
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo

        switch channels {
        case .rgb:
            bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
        case .rgba:
            bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        }

        // Create data provider from pixel data
        guard let dataProvider = CGDataProvider(data: pixels as CFData) else {
            return nil
        }

        // Create CGImage
        return CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
    }
}
