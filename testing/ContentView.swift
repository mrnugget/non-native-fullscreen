//
//  ContentView.swift
//  testing
//
//  Created by Thorsten Ball on 01.07.23.
//

import SwiftUI

class FullScreenHandler {
    var previousScreen: NSScreen?
    var previousContentFrame: NSRect?
    var previousStyleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]
    var isInFullscreen: Bool = false
    var isAnimating: Bool = false
    
    func toggleFullscreen(window: NSWindow) {
        if isAnimating {
            return
        }
        
        isAnimating = true
        
        if isInFullscreen {
            leaveFullscreen(window: window)
        } else {
            enterFullscreen(window: window)
        }
    }
    
    func leaveFullscreen(window: NSWindow) {
        guard let screen = window.screen  else { return }
        guard let systemBar = window.standardWindowButton(.closeButton)?.superview else { return }
        
        // Restore previous style
        window.styleMask = previousStyleMask
        window.titlebarAppearsTransparent = false
        window.isMovable = true
        
        // Restore previous presentation options
        NSApp.presentationOptions = []
        
        let newFrame = calculateWindowPosition(window: window, for: screen)
        window.setFrame(newFrame, display: true)
        
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.0
            systemBar.animator().alphaValue = 1
        }, completionHandler: {
            self.isInFullscreen = false
            self.isAnimating = false
        })
    }
    
    func enterFullscreen(window: NSWindow) {
        guard let screen = window.screen  else { return }
        guard let systemBar = window.standardWindowButton(.closeButton)?.superview else { return }
        
        // Save previous style mask
        previousStyleMask = window.styleMask
        
        // Save previous contentViewFrame and screen
        if let contentViewFrame = window.contentView?.frame {
            previousContentFrame = window.convertToScreen(contentViewFrame)
            previousScreen = window.screen
        }
        
        // Change presentation style to hide menu bar and dock
        NSApp.presentationOptions = [.autoHideMenuBar, .autoHideDock]
        // Turn it into borderless window
        window.styleMask.insert(.borderless)
        
        // Update these
        window.titlebarAppearsTransparent = true // this removes the border between titlebar and content
        window.isMovable = false // non movable
        
        // Set frame to screen size
        window.setFrame(CGRect(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height), display: true)
        
        // This sets the size of the contentView to the screen size, which should give us full content
        if let view = window.contentView {
            view.setFrameSize(NSMakeSize(screen.frame.width, screen.frame.height))
        }
        
        // Now we hide the systembar (the title bar) with a 0-sec animation
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.0
            systemBar.animator().alphaValue = 0
        }, completionHandler: {
            self.isInFullscreen = true
            self.isAnimating = false
        })
    }
    
    func calculateWindowPosition(window: NSWindow, for targetScreen: NSScreen) -> NSRect {
        guard let contentFrame = previousContentFrame, let screen = previousScreen else {
            return window.frame
        }
        
        var newFrame = window.frameRect(forContentRect: contentFrame)
        let targetFrame = targetScreen.frame
        let targetVisibleFrame = targetScreen.visibleFrame
        let unfsScreenFrame = screen.frame
        let visibleWindow = NSIntersectionRect(unfsScreenFrame, newFrame)
        
        // calculate visible area of every side
        let left = newFrame.origin.x - unfsScreenFrame.origin.x
        let right = unfsScreenFrame.size.width - (newFrame.origin.x - unfsScreenFrame.origin.x + newFrame.size.width)
        let bottom = newFrame.origin.y - unfsScreenFrame.origin.y
        let top = unfsScreenFrame.size.height - (newFrame.origin.y - unfsScreenFrame.origin.y + newFrame.size.height)
        
        // normalize visible areas, decide which one to take horizontal/vertical
        var xPer = (unfsScreenFrame.size.width - visibleWindow.size.width)
        var yPer = (unfsScreenFrame.size.height - visibleWindow.size.height)
        if xPer != 0 { xPer = (left >= 0 || right < 0 ? left : right) / xPer }
        if yPer != 0 { yPer = (bottom >= 0 || top < 0 ? bottom : top) / yPer }
        
        // calculate visible area for every side for target screen
        let xNewLeft = targetFrame.origin.x + (targetFrame.size.width - visibleWindow.size.width) * xPer
        let xNewRight = targetFrame.origin.x + targetFrame.size.width - (targetFrame.size.width - visibleWindow.size.width) * xPer - newFrame.size.width
        let yNewBottom = targetFrame.origin.y + (targetFrame.size.height - visibleWindow.size.height) * yPer
        let yNewTop = targetFrame.origin.y + targetFrame.size.height - (targetFrame.size.height - visibleWindow.size.height) * yPer - newFrame.size.height
        
        // calculate new coordinates, decide which one to take horizontal/vertical
        newFrame.origin.x = left >= 0 || right < 0 ? xNewLeft : xNewRight
        newFrame.origin.y = bottom >= 0 || top < 0 ? yNewBottom : yNewTop
        
        // don't place new window on top of a visible menubar
        let topMar = targetFrame.size.height - (newFrame.origin.y - targetFrame.origin.y + newFrame.size.height)
        let menuBarHeight = targetFrame.size.height - (targetVisibleFrame.size.height + targetVisibleFrame.origin.y)
        if topMar < menuBarHeight {
            newFrame.origin.y -= top - menuBarHeight
        }
        
        return newFrame
    }
}

struct ContentView: View {
    @State var fsHandler = FullScreenHandler()
    @State private var someText: String = ""
    
    var body: some View {
        ZStack {
            Color.purple
                .ignoresSafeArea()
            
            
            VStack {
                TextField(
                    "Type something in here to test that typing works",
                    text: $someText
                )
                
                Button("Toggle fullscreen") {
                    self.toggle()
                }
                .keyboardShortcut("f", modifiers: [.command])
            }
        }
    }
    
    func toggle() {
        guard let currentWindow = NSApp.keyWindow else { return }
        self.fsHandler.toggleFullscreen(window: currentWindow)
    }
}
