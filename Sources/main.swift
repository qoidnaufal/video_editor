@preconcurrency import AVFoundation
import AVKit
import SwiftUI
import Cocoa

@MainActor
class VideoEditor {
	var avPlayerItem: AVPlayerItem? = nil
	var avPlayer: AVPlayer? = nil

	private var asset: AVAsset

	init(url: URL) {
		let url = url
		let asset = AVURLAsset(url: url)
		let item = AVPlayerItem(asset: asset)

		self.asset = asset
		self.avPlayerItem = item
		self.avPlayer = AVPlayer(playerItem: item)

		Task(priority: .medium) {
			try await buildVideo()
		}
	}

	private func buildComposition() async throws -> AVVideoComposition {
		let composition = try await AVMutableVideoComposition.videoComposition(withPropertiesOf: asset)
		// composition.renderScale = 2.0
		// composition.renderSize = CGSize(width: 500.0, height: 400.0)
		// composition.frameDuration = CMTime(value: 1, timescale: 1)

		return composition
	}

	func buildVideo() async throws {
		guard let item = avPlayerItem else { return }
		item.videoComposition = try await buildComposition()
	}
}

@MainActor
struct MyAppView: View {
	let videoEditor = VideoEditor(url: URL(filePath: .init("../../LearnRust/vid2.mp4"))!)
	var body: some View {
		VideoPlayer(player: videoEditor.avPlayer)
	}
}

extension NSApplication {
    public func run<V: View>(@ViewBuilder view: () -> V) {
        let appDelegate = AppDelegate(view())
        NSApp.setActivationPolicy(.regular)
        mainMenu = customMenu
        delegate = appDelegate
        run()
    }
}

extension NSApplication {
    var customMenu: NSMenu {
        let appMenu = NSMenuItem()
        appMenu.submenu = NSMenu()
        let appName = ProcessInfo.processInfo.processName
        appMenu.submenu?.addItem(NSMenuItem(title: "About \(appName)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""))
        appMenu.submenu?.addItem(NSMenuItem.separator())
        let services = NSMenuItem(title: "Services", action: nil, keyEquivalent: "")
        self.servicesMenu = NSMenu()
        services.submenu = self.servicesMenu
        appMenu.submenu?.addItem(services)
        appMenu.submenu?.addItem(NSMenuItem.separator())
        appMenu.submenu?.addItem(NSMenuItem(title: "Hide \(appName)", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h"))
        let hideOthers = NSMenuItem(title: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
        hideOthers.keyEquivalentModifierMask = [.command, .option]
        appMenu.submenu?.addItem(hideOthers)
        appMenu.submenu?.addItem(NSMenuItem(title: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: ""))
        appMenu.submenu?.addItem(NSMenuItem.separator())
        appMenu.submenu?.addItem(NSMenuItem(title: "Quit \(appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        let windowMenu = NSMenuItem()
        windowMenu.submenu = NSMenu(title: "Window")
        windowMenu.submenu?.addItem(NSMenuItem(title: "Minmize", action: #selector(NSWindow.miniaturize(_:)), keyEquivalent: "m"))
        windowMenu.submenu?.addItem(NSMenuItem(title: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: ""))
        windowMenu.submenu?.addItem(NSMenuItem.separator())
        windowMenu.submenu?.addItem(NSMenuItem(title: "Show All", action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: "m"))
        
        let mainMenu = NSMenu(title: "Main Menu")
        mainMenu.addItem(appMenu)
        mainMenu.addItem(windowMenu)
        return mainMenu
    }
}

class AppDelegate<V: View>: NSObject, NSApplicationDelegate, NSWindowDelegate {
    init(_ contentView: V) {
        self.contentView = contentView
        
    }
    var window: NSWindow!
    var hostingView: NSView?
    var contentView: V
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1280, height: 720),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        hostingView = NSHostingView(rootView: contentView)
        window.contentView = hostingView
        window.makeKeyAndOrderFront(nil)
        window.delegate = self
        NSApp.activate(ignoringOtherApps: true)
    }
}

NSApplication.shared.run {
    VStack {
		MyAppView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
