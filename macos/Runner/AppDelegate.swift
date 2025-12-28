import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Personalizar o menu "Sobre"
    if let mainMenu = NSApp.mainMenu {
      if let appMenu = mainMenu.item(at: 0)?.submenu {
        // Encontrar o item "About"
        if let aboutItem = appMenu.item(withTitle: "About Nova Extract") {
          aboutItem.target = self
          aboutItem.action = #selector(showAboutPanel)
        }
      }
    }
    
    super.applicationDidFinishLaunching(notification)
  }
  
  @objc func showAboutPanel() {
    let aboutInfo = """
    NovaExtract
    
    Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
    
    A powerful and intuitive file extraction and compression tool.
    
    Supported formats for extraction:
    • ZIP, TAR, TAR.GZ, TAR.BZ2, GZ, BZ2
    
    Supported formats for compression:
    • ZIP, TAR, TAR.GZ, TAR.BZ2
    
    Developed by Artur Martins - Tirano Tech
    
    Copyright © 2025 Artur Martins - Tirano Tech. All rights reserved.
    """
    
    let options: [NSApplication.AboutPanelOptionKey: Any] = [
      .applicationName: "NovaExtract",
      .applicationVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
      .credits: NSAttributedString(string: aboutInfo),
    ]
    
    NSApp.orderFrontStandardAboutPanel(options: options)
  }
  
  // Handler para serviços do menu de contexto
  override func application(_ application: NSApplication, open urls: [URL]) {
    guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else {
      return
    }
    
    let channel = FlutterMethodChannel(
      name: "com.tiranotech.novaextract/services",
      binaryMessenger: controller.engine.binaryMessenger
    )
    
    let filePaths = urls.map { $0.path }
    channel.invokeMethod("handleService", arguments: ["paths": filePaths])
  }
}
