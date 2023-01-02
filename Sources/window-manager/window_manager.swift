import Cocoa

@main
public struct window_manager {
  public static func main() {
    let fileName =
      "\(ProcessInfo.processInfo.environment["HOME"] ?? "")/Library/Preferences/com.apple.spaces.plist"
    let spacesPlist = readPlist(fileName: fileName)
    // print(spacesPlist)
    let sp = spacesPlist.spacesDisplayConfiguration.spaceProperties
    let windowIdsSet = Set(sp.flatMap { property in property.windows })
    let windowDictDict = getWindowDicts(windowIds: windowIdsSet)

    var i = 1
    sp.forEach { prop in
      print("Desktop", i, prop.name)
      prop.windows.forEach { id in
        if let windowDict = windowDictDict[id] as? [String: Any] {
          if let name = windowDict[kCGWindowName as String] as? String {
            print(id, name)
          }
        } else {
          print(id, "probably signal?")
        }
        // print(id, windowDictDict[id] ?? [:])
      }
      i += 1
    }
  }
}
