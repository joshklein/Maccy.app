import Cocoa
import Defaults
import SwiftUI

enum MenuFooter: Int, CaseIterable {
  case separator = 100
  case clear = 101
  case clearAll = 106
  case preferences = 107
  case about = 103
  case quit = 104

  var menuItem: NSMenuItem {
    let item = self == .separator ? NSMenuItem.separator() : NSMenuItem()
    item.isAlternate = isAlternate && Defaults[.showFooter]
    item.isHidden = !Defaults[.showFooter]
    item.keyEquivalent = keyEquivalent
    item.keyEquivalentModifierMask = keyEquivalentModifierMask
    item.tag = rawValue
    item.title = title
    item.toolTip = tooltip
    return item
  }

  var isAlternate: Bool {
    switch self {
    case .clearAll:
      return true
    default:
      return false
    }
  }

  var keyEquivalent: String {
    switch self {
    case .clear, .clearAll:
      return "⌫"
    case .quit:
      return "q"
    case .preferences:
      return ","
    default:
      return ""
    }
  }

  var keyEquivalentModifierMask: NSEvent.ModifierFlags {
    switch self {
    case .clear:
      return [.command, .option]
    case .clearAll:
      return [.command, .option, .shift]
    case .quit:
      return [.command]
    case .preferences:
      return [.command]
    default:
      return []
    }
  }

  var eventModifiers: EventModifiers {
    switch self {
    case .clear:
      return .init(arrayLiteral: [.command, .option])
    case .clearAll:
      return .init(arrayLiteral: [.command, .option, .shift])
    case .quit:
      return .init(arrayLiteral: [.command])
    case .preferences:
      return .init(arrayLiteral: [.command])
    default:
      return .init(arrayLiteral: [])
    }
  }

  var title: String {
    switch self {
    case .clear:
      return NSLocalizedString("clear", comment: "")
    case .clearAll:
      return NSLocalizedString("clear_all", comment: "")
    case .about:
      return NSLocalizedString("about", comment: "")
    case .quit:
      return NSLocalizedString("quit", comment: "")
    case .preferences:
      return NSLocalizedString("preferences", comment: "")
    default:
      return ""
    }
  }

  var tooltip: String {
    switch self {
    case .clear:
      return NSLocalizedString("clear_tooltip", comment: "")
    case .clearAll:
      return NSLocalizedString("clear_all_tooltip", comment: "")
    case .about:
      return NSLocalizedString("about_tooltip", comment: "")
    case .quit:
      return NSLocalizedString("quit_tooltip", comment: "")
    default:
      return ""
    }
  }
}
