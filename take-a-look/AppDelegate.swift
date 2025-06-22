import Cocoa
import SwiftUI

struct FullScreen {
    static var width: CGFloat {
        NSScreen.main?.frame.size.width ?? 0
    }
    static var height: CGFloat {
        NSScreen.main?.frame.size.height ?? 0
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem?
    var window: NSWindow?
    var eventMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        if let window = NSApp.windows.first {
            let screenFrame = NSScreen.main?.visibleFrame ?? .zero
            let windowSize = window.frame.size
            let origin = CGPoint(x: screenFrame.minX, y: screenFrame.maxY - windowSize.height)
            window.setFrameOrigin(origin)
            
            window.styleMask.remove([.titled, .closable, .miniaturizable])
            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = false
            window.level = .mainMenu + 1
            window.isMovableByWindowBackground = true // Enable dragging by background
        }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "pawprint", accessibilityDescription: "TAL")
            button.image?.isTemplate = true
            button.action = #selector(toggleWindow)
        }
    }
    
    @objc func toggleWindow() {
        if window == nil {
            let contentView = ZStack {
                SettingsView()
            }
            
            window = NSWindow( // Changed back to NSWindow
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window?.isReleasedWhenClosed = false
            window?.hasShadow = true
            window?.level = .floating
            window?.ignoresMouseEvents = false
            window?.backgroundColor = .clear
            window?.isOpaque = false
            window?.delegate = self
            
            window?.titleVisibility = .hidden
            window?.titlebarAppearsTransparent = true
            window?.styleMask.insert(.fullSizeContentView)
            window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            
            // Changed back to using NSHostingView
            let hostingView = NSHostingView(rootView: contentView)
            hostingView.wantsLayer = true
            hostingView.layer?.cornerRadius = 16
            hostingView.layer?.masksToBounds = true
            window?.contentView = hostingView
        }
        
        if window?.isVisible == true {
            window?.orderOut(nil)
            stopEventMonitor()
        } else {
            DispatchQueue.main.async {
                if let button = self.statusItem?.button, let window = self.window {
                    if let _ = button.window?.screen {
                        let buttonFrame = button.window?.convertToScreen(button.frame) ?? .zero
                        
                        let xPos = buttonFrame.maxX - window.frame.width
                        let yPos = buttonFrame.minY - window.frame.height
                        
                        window.setFrameOrigin(NSPoint(x: xPos, y: yPos))
                    }
                }
                self.window?.makeKeyAndOrderFront(nil)
                self.startEventMonitor()
            }
        }
    }
    
    func windowDidResignKey(_ notification: Notification) {
        window?.orderOut(nil)
        stopEventMonitor()
    }
    
    func startEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            self?.window?.orderOut(nil)
            self?.stopEventMonitor()
        }
    }
    
    func stopEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}

class PopupWindowManager {
    static let shared = PopupWindowManager()
    
    private var window: NSWindow?
    
    func showPopup<Content: View>(@ViewBuilder content: () -> Content) {
        if window == nil {
            let hostingView = NSHostingView(rootView: content())
            
            window = NSWindow(
                contentRect: NSScreen.main?.frame ?? .zero,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            
            window?.contentView = hostingView
            window?.level = .statusBar + 1
            window?.isReleasedWhenClosed = false
            window?.makeKeyAndOrderFront(nil)
            window?.backgroundColor = .clear
            window?.isOpaque = false
            
            window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            
            // 💡 위치를 명확히 잡아주기
            if let screenFrame = NSScreen.main?.frame {
                window?.setFrameOrigin(NSPoint(x: screenFrame.minX, y: screenFrame.minY))
            }
        }
    }
    
    func closePopup() {
        window?.orderOut(nil)
        window = nil
    }
}
