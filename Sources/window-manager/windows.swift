import Cocoa

/* true return means has permission */
func permissionCheck() -> Bool {
  // https://www.ryanthomson.net/articles/screen-recording-permissions-catalina-mess/
  // Runs permission check
  let stream = CGDisplayStream(
    display: CGMainDisplayID(),
    outputWidth: 1,
    outputHeight: 1,
    pixelFormat: Int32(kCVPixelFormatType_32BGRA),
    properties: nil,
    handler: { _, _, _, _ in }
  )
  stream?.stop()
  return stream != nil
}

func readPlist(fileName: String) -> SpacesPlist {
  let fileURL = URL(fileURLWithPath: fileName)
  // print(try? fileURL.checkResourceIsReachable())
  guard let tempData = NSData(contentsOf: fileURL) else {
    return SpacesPlist(spacesDisplayConfiguration: SpacesDisplayConfiguration(spaceProperties: []))
  }
  let plist = try! PropertyListDecoder().decode(SpacesPlist.self, from: tempData as Data)
  return plist
}
struct SpacesPlist: Codable {
  let spacesDisplayConfiguration: SpacesDisplayConfiguration

  enum CodingKeys: String, CodingKey {
    case spacesDisplayConfiguration = "SpacesDisplayConfiguration"
  }
}
struct SpacesDisplayConfiguration: Codable {
  let spaceProperties: [SpaceProperty]

  enum CodingKeys: String, CodingKey {
    case spaceProperties = "Space Properties"
  }
}
struct SpaceProperty: Codable {
  let name: String
  let windows: [Int]
}

func getWindowDicts(windowIds: Set<Int>) -> [Int: Any] {
  var returnDict = [Int: Any]()
  if let windowInfo = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) as? [[String: Any]] {
    for windowDict in windowInfo {
      if let windowId = windowDict[kCGWindowNumber as String] as? CGWindowID {
        let intWindowId = Int(windowId)
        if let name = windowDict[kCGWindowName as String] as? String {
          // print(intWindowId, name)
        }
        if windowIds.contains(intWindowId) {
          returnDict[intWindowId] = windowDict
        }
      }
    }
  }
  return returnDict
}

func saveScreenshots(windowIds: Set<Int>) {
  if let windowInfo = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) as? [[String: Any]] {
    // print(windowInfo)

    for windowDict in windowInfo {
      if let windowName = windowDict[kCGWindowName as String] as? String,
        let windowId = windowDict[kCGWindowNumber as String] as? CGWindowID
      {
        if windowIds.contains(Int(windowId)) && windowName.count > 0 {
          let fileName = "/tmp/testing-screen-\(windowName).png"
          let fileUrl = URL(fileURLWithPath: fileName)
          print("saving", fileName)
          saveImage(forWindow: windowId, to: fileUrl)
        }
      }
    }
  }
}
func saveImage(forWindow windowId: CGWindowID, to url: URL) {
  guard
    let cgimage = CGWindowListCreateImage(
      .null, [.optionIncludingWindow], windowId, [.nominalResolution])
  else { return }
  let imageRep = NSBitmapImageRep(cgImage: cgimage)
  let pngData = imageRep.representation(using: .png, properties: [:])
  try? pngData!.write(to: url)
}
