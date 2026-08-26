import CoreGraphics
import Foundation

guard CommandLine.arguments.count >= 2,
      let keyCode = UInt16(CommandLine.arguments[1]) else {
  fputs("usage: ax-key <key-code> [control] [option] [command] [shift]\n", stderr)
  exit(2)
}

var flags: CGEventFlags = []
for modifier in CommandLine.arguments.dropFirst(2) {
  switch modifier {
  case "control": flags.insert(.maskControl)
  case "option": flags.insert(.maskAlternate)
  case "command": flags.insert(.maskCommand)
  case "shift": flags.insert(.maskShift)
  default:
    fputs("unsupported modifier: \(modifier)\n", stderr)
    exit(2)
  }
}

let source = CGEventSource(stateID: .hidSystemState)
for isDown in [true, false] {
  guard let event = CGEvent(
    keyboardEventSource: source,
    virtualKey: CGKeyCode(keyCode),
    keyDown: isDown
  ) else {
    fputs("could not create keyboard event\n", stderr)
    exit(1)
  }
  event.flags = flags
  event.post(tap: .cghidEventTap)
  usleep(120_000)
}
