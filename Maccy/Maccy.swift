import Cocoa

class Maccy: NSObject {
  @objc let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

  private let about = About()
  private let menu = Menu(title: "Maccy")

  private let pasteByDefault = "pasteByDefault"
  private let saratovSeparator = "enableSaratovSeparator"

  private var showInStatusBar: String {
    if ProcessInfo.processInfo.arguments.contains("ui-testing") {
      return "showInStatusBarUITests"
    } else {
      return "showInStatusBar"
    }
  }

  private let history: History
  private let clipboard: Clipboard

  private var clearItem: NSMenuItem {
    let item = NSMenuItem(title: "Clear", action: #selector(clear), keyEquivalent: "")
    item.target = self
    return item
  }

  private var aboutItem: NSMenuItem {
    let item = NSMenuItem(title: "About", action: #selector(about.openAbout), keyEquivalent: "")
    item.target = about
    return item
  }

  private var observation: NSKeyValueObservation?

  init(history: History, clipboard: Clipboard) {
    self.history = history
    self.clipboard = clipboard
    super.init()

    menu.history = history
    UserDefaults.standard.register(defaults: [showInStatusBar: true, pasteByDefault: false, saratovSeparator: false])
    observation = observe(\.statusItem.isVisible, options: [.new], changeHandler: { _, change in
      UserDefaults.standard.set(change.newValue!, forKey: self.showInStatusBar)
    })
  }

  func start() {
    statusItem.button?.image = NSImage(named: "StatusBarMenuImage")
    statusItem.menu = menu
    statusItem.behavior = .removalAllowed

    if ProcessInfo.processInfo.arguments.contains("ui-testing") {
      statusItem.isVisible = true
    } else {
      statusItem.isVisible = UserDefaults.standard.bool(forKey: showInStatusBar)
    }

    refresh()

    clipboard.onNewCopy(history.add)
    clipboard.onNewCopy({ (_ string: String) -> Void in self.refresh() })
    clipboard.onRemovedCopy(history.removeRecent)
    clipboard.onRemovedCopy({ self.refresh() })

    clipboard.startListening()
  }

  func popUp() {
    menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
  }

  private func refresh() {
    menu.allItems.removeAll()
    menu.addSearchItem()
    populateItems()
    populateFooter()
  }

  private func populateItems() {
    let pasteByDefault = UserDefaults.standard.bool(forKey: self.pasteByDefault)
    for entry in history.all() {
      if pasteByDefault {
        addPasteSearchItem(entry, alt: false)
        addCopySearchItem(entry, alt: true)
      } else {
        addCopySearchItem(entry, alt: false)
        addPasteSearchItem(entry, alt: true)
      }
    }
  }

  private func populateFooter() {
    menu.addItem(NSMenuItem.separator())
    menu.addItem(clearItem)
    if UserDefaults.standard.bool(forKey: saratovSeparator) {
      menu.addItem(NSMenuItem.separator())
    }
    menu.addItem(aboutItem)
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.stop), keyEquivalent: "q"))
  }

  private func addCopySearchItem(_ entry: String, alt: Bool) {
    let menuItem = HistoryMenuItem(title: entry, onSelected: copy(_:))
    if alt {
      alternate(menuItem)
    }
    menu.addItem(menuItem)
  }

  private func addPasteSearchItem(_ entry: String, alt: Bool) {
    let menuItem = HistoryMenuItem(title: entry, onSelected: { item in
      self.copy(item)
      self.clipboard.paste()
    })
    if alt {
      alternate(menuItem)
    }
    menu.addItem(menuItem)
  }

  private func alternate(_ menuItem: HistoryMenuItem) {
    menuItem.keyEquivalentModifierMask = [.option]
    menuItem.isHidden = true
    menuItem.isAlternate = true
  }

  private func copy(_ item: HistoryMenuItem) {
    guard let title = item.fullTitle else {
      return
    }

    clipboard.copy(title)
  }

  @objc
  func clear(_ sender: NSMenuItem) {
    history.clear()
    refresh()
  }
}
