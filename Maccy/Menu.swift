import AppKit

// Custom menu supporting "search-as-you-type" based on https://github.com/mikekazakov/MGKMenuWithFilter.
class Menu: NSMenu, NSMenuDelegate {
  public let maxHotKey = 9
  private let lastCopiedItemIndexDelta = 5

  required init(coder decoder: NSCoder) {
    super.init(coder: decoder)
  }

  override init(title: String) {
    super.init(title: title)
    self.delegate = self
  }

  func menuWillOpen(_ menu: NSMenu) {
    let highlightItemSelector = NSSelectorFromString("highlightItem:")
    perform(highlightItemSelector, with: item(at: 1))
  }

  func addSearchItem() {
    let headerItemView = FilterMenuItemView(frame: NSRect(x: 0, y: 0, width: 20, height: 29))
    headerItemView.title = title

    let headerItem = NSMenuItem()
    headerItem.title = title
    headerItem.view = headerItemView

    addItem(headerItem)
  }

  func updateFilter(filter: String) {
    var index = 0
    for item in items[1...(items.count - 1)] {
      item.isHidden = !validateItemWithFilter(item, filter)
      if !isSystemItem(item: item) {
        if !item.isHidden && index < maxHotKey {
          index += 1
          item.keyEquivalent = String(index)
        } else {
          item.keyEquivalent = ""
        }
      }
    }

    var itemToHighlight: NSMenuItem?
    for item in items[1...(items.count - 1)] {
      if !item.isHidden && item.isEnabled {
        itemToHighlight = item
        break
      }
    }

    if itemToHighlight != nil {
      let highlightItemSelector = NSSelectorFromString("highlightItem:")
      perform(highlightItemSelector, with: itemToHighlight)
    }
  }

  func select() {
    if let item = highlightedItem {
      performActionForItem(at: index(of: item))
      cancelTracking()
    }
  }

  func selectPrevious() {
    var indexToHighlight = items.count - lastCopiedItemIndexDelta
    if let item = highlightedItem {
      indexToHighlight = index(of: item) - 1
    }

    if let itemToHighlight = self.item(at: indexToHighlight) {
      let highlightItemSelector = NSSelectorFromString("highlightItem:")
      perform(highlightItemSelector, with: itemToHighlight)

      if itemToHighlight.isSeparatorItem || !itemToHighlight.isEnabled || itemToHighlight.isHidden {
        selectPrevious()
      }
    }
  }

  func selectNext() {
    var indexToHighlight = 1
    if let item = highlightedItem {
      indexToHighlight = index(of: item) + 1
    }

    if let itemToHighlight = self.item(at: indexToHighlight) {
      let highlightItemSelector = NSSelectorFromString("highlightItem:")
      perform(highlightItemSelector, with: itemToHighlight)

      if itemToHighlight.isSeparatorItem || !itemToHighlight.isEnabled || itemToHighlight.isHidden {
        selectNext()
      }
    }
  }

  private func validateItemWithFilter(_ item: NSMenuItem, _ filter: String) -> Bool {
    if filter.isEmpty || item.isSeparatorItem || isSystemItem(item: item) {
      return true
    }

    if !item.isEnabled {
      return false
    }

    let range = item.title.range(
      of: filter,
      options: .caseInsensitive,
      range: nil,
      locale: nil
    )

    return (range != nil)
  }

  private func isSystemItem(item: NSMenuItem) -> Bool {
    switch item.title {
    case "Clear", "About", "Quit":
      return true
    default:
      return false
    }
  }
}
