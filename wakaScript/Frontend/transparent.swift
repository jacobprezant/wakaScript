//
//  transparent.swift
//  wakaScript
//
//  Created by Jacob on 6/24/25.
//

import SwiftUI

struct WindowAccessor: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(WindowConfigurator())
    }

    struct WindowConfigurator: NSViewRepresentable {
        func makeNSView(context: Context) -> NSView {
            let view = NSView()
            DispatchQueue.main.async {
                if let window = view.window {
                    window.isOpaque = false
                    window.backgroundColor = .clear
                    window.alphaValue = 0.85
                }
            }
            return view
        }
        func updateNSView(_ nsView: NSView, context: Context) {}
    }
}

extension View {
    func transparentWindow() -> some View {
        self.modifier(WindowAccessor())
    }
}

struct HideZoomButton: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        DispatchQueue.main.async {
            if let window = NSApp.windows.first {
                window.standardWindowButton(.zoomButton)?.isHidden = true
            }
        }
        return NSView()
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

extension View {
    func hideZoomButton() -> some View {
        self.background(HideZoomButton())
    }
}
