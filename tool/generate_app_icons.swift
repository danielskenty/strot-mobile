import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

guard CommandLine.arguments.count == 3 else {
  fputs("Usage: generate_app_icons.swift INPUT OUTPUT\n", stderr)
  exit(64)
}

let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
guard let source = NSImage(contentsOf: inputURL) else {
  fputs("Unable to read source image\n", stderr)
  exit(65)
}
var sourceRect = NSRect(origin: .zero, size: source.size)
guard let sourceImage = source.cgImage(forProposedRect: &sourceRect, context: nil, hints: nil) else {
  fputs("Unable to decode source image\n", stderr)
  exit(65)
}

let pixels = 1024
let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let context = CGContext(
  data: nil,
  width: pixels,
  height: pixels,
  bitsPerComponent: 8,
  bytesPerRow: 0,
  space: colorSpace,
  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
) else {
  fputs("Unable to create drawing context\n", stderr)
  exit(70)
}

context.setFillColor(
  red: 247.0 / 255.0,
  green: 243.0 / 255.0,
  blue: 234.0 / 255.0,
  alpha: 1
)
context.fill(CGRect(x: 0, y: 0, width: pixels, height: pixels))

let safeExtent: CGFloat = 760
let sourceSize = CGSize(width: sourceImage.width, height: sourceImage.height)
let scale = min(safeExtent / sourceSize.width, safeExtent / sourceSize.height)
let drawnSize = CGSize(width: sourceSize.width * scale, height: sourceSize.height * scale)
let target = CGRect(
  x: (CGFloat(pixels) - drawnSize.width) / 2,
  y: (CGFloat(pixels) - drawnSize.height) / 2,
  width: drawnSize.width,
  height: drawnSize.height
)
context.interpolationQuality = .high
context.draw(sourceImage, in: target)

guard
  let result = context.makeImage(),
  let destination = CGImageDestinationCreateWithURL(
    outputURL as CFURL,
    UTType.png.identifier as CFString,
    1,
    nil
  )
else {
  fputs("Unable to prepare output PNG\n", stderr)
  exit(70)
}
CGImageDestinationAddImage(destination, result, nil)
guard CGImageDestinationFinalize(destination) else {
  fputs("Unable to encode output PNG\n", stderr)
  exit(70)
}
