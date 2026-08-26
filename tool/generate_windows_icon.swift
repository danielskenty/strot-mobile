import Foundation

guard CommandLine.arguments.count >= 4 else {
  fputs("Usage: generate_windows_icon.swift OUTPUT SIZE:PNG [SIZE:PNG ...]\n", stderr)
  exit(64)
}

let outputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let entries: [(size: Int, data: Data)] = try CommandLine.arguments.dropFirst(2).map {
  let parts = $0.split(separator: ":", maxSplits: 1).map(String.init)
  guard parts.count == 2, let size = Int(parts[0]), (1...256).contains(size) else {
    throw NSError(domain: "STROTIcon", code: 64)
  }
  return (size, try Data(contentsOf: URL(fileURLWithPath: parts[1])))
}

func littleEndianBytes<T: FixedWidthInteger>(_ value: T) -> [UInt8] {
  withUnsafeBytes(of: value.littleEndian, Array.init)
}

var icon = Data()
icon.append(contentsOf: littleEndianBytes(UInt16(0)))
icon.append(contentsOf: littleEndianBytes(UInt16(1)))
icon.append(contentsOf: littleEndianBytes(UInt16(entries.count)))

var offset = 6 + (16 * entries.count)
for entry in entries {
  icon.append(UInt8(entry.size == 256 ? 0 : entry.size))
  icon.append(UInt8(entry.size == 256 ? 0 : entry.size))
  icon.append(0)
  icon.append(0)
  icon.append(contentsOf: littleEndianBytes(UInt16(1)))
  icon.append(contentsOf: littleEndianBytes(UInt16(32)))
  icon.append(contentsOf: littleEndianBytes(UInt32(entry.data.count)))
  icon.append(contentsOf: littleEndianBytes(UInt32(offset)))
  offset += entry.data.count
}
for entry in entries {
  icon.append(entry.data)
}
try icon.write(to: outputURL, options: .atomic)
