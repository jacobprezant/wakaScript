//
//  AccessibilityWizardView.swift
//  wakaScript
//
//  Created by Jacob on 6/24/25.
//


import SwiftUI
import Cocoa

struct AccessibilityWizardView: View {
    @State private var showOpenSourceInfo = false
    @EnvironmentObject var permissions: PermissionChecker
    @State private var accessibilityGranted = false
    @State private var step = 1
    
    var body: some View {
        VStack(spacing: 20) {
            switch step {
            case 1:
                HStack {
                    Image(systemName: "accessibility")
                        .font(.system(size: 50))
                    Image(systemName: "hand.raised.palm.facing.fill")
                        .font(.system(size: 50))
                }
                Text("We know you want to get *right* to scripting, but first wakaScript needs a couple of accessibility permissions.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Accessibility permissions let wakaScript interact with your Mac and get information about Script Editor that WakaTime needs for sending heartbeats.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                Text("The actual contents of your scripts **never** leave your Mac. These permissions are required to use wakaScript.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Text("wakaScript is open-source")
                    Button(action: { showOpenSourceInfo = true }) {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .popover(isPresented: $showOpenSourceInfo) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What's Open-Source ?")
                                .font(.headline)
                            Text("wakaScript is fully open-source. Anyone—including you—can inspect the code to verify exactly what it does, making it transparent and safe to use.")
                            Text("Give wakaScript a ") +
                            Text(Image(systemName: "star.fill"))
                                .foregroundColor(.yellow)
                            + Text(" on GitHub if you found it useful!")
                            
                            Link("View on GitHub", destination: URL(string: "https://github.com/jacobprezant/wakaScript")!)
                            Button("Close") { showOpenSourceInfo = false }
                                .padding(.top)
                        }
                        .padding()
                        .frame(width: 300)
                    }
                }
                Button("Let's go 🚀") {
                    step = 2
                }
                .padding(.top, 10)
            case 2:
                Text("Here, we'll grant wakaScript Accessbility permissions. This allows us to observe and interact with Script Editor, so that we can detect when scripts are saved and when the focused file has changed.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Click the button below, select the plus icon, authenticate, and then select **wakaScript** from your Applications.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Grant Accessibility Permission"){
                    _ = requestAccessibilityPermissions()
                    step = 3
                }
            case 3:
                Text("Let's check if that went through.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Check Accessibility Permission") {
                    accessibilityGranted = isAccessibilityGranted()
                    if AXIsProcessTrusted() {
                        step = 4 //go to automator
                    } else {
                        step = 5 // not granted
                    }
                }
            case 4:
                Image(systemName: "hand.thumbsup.fill")
                    .font(.system(size: 50))
                Text("Great! That's all done.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Now, we'll give wakaScript automator permissions which lets us execute applescript. This is needed for detecting script edits.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Click the button below which will prompt you for the permission.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Grant Automator Permission") {
                    let script = """
                    tell application "System Events"
                        set _ to name of processes
                    end tell
                    """
                    NSAppleScript(source: script)?.executeAndReturnError(nil)
                    step = 6
                }
            case 5:
                Image(systemName: "xmark")
                    .font(.system(size: 50))
                Text("Looks like the permission was **not** granted. Let's try again below. You won't be able to proceed without this permission.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Grant Accessibility Permission"){
                    _ = requestAccessibilityPermissions()
                    
                    step = 3
                }
            case 6:
                Text("Let's check if that went through.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Check Automator Permission") {
                    let targetBundleID = "com.apple.systemevents"
                    let targetDesc = NSAppleEventDescriptor(bundleIdentifier: targetBundleID)
                    let status = AEDeterminePermissionToAutomateTarget(targetDesc.aeDesc, typeWildCard, typeWildCard, true)
                    if status == 0 {
                        step = 7 // Permission granted
                    } else if status == -1743 {
                        step = 8 // Permission denied
                    }
                }
            case 7:
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                Text("Great! That's all done.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                Button("You're ready to get started! ✈️") {
                    permissions.checkPermissions()
                }
            case 8:
                Image(systemName: "xmark")
                    .font(.system(size: 50))
                Text("Looks like the permission was **not** granted. You won't be able to proceed without this permission. Click the button below, and then select the checkbox next to System Events under wakaScript to grant permission.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Take me to the settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
                                    NSWorkspace.shared.open(url)
                                }
                            }
                Text("Click the button below once you're ready to proceed.")
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 320, alignment: .leading)
                Button("I'm ready. I've enabled System Events for wakaScript.") {
                    step = 6
                }
            default:
                EmptyView()
            }
        }
        .padding(.bottom, 40)
        .frame(width: 400, height: 400)
        .onAppear {
            permissions.checkPermissions()
        }
    }
}
        
func isAccessibilityGranted() -> Bool {
    AXIsProcessTrusted()
}

func requestAccessibilityPermissions() {
    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
    _ = AXIsProcessTrustedWithOptions(options)
}

#Preview {
    AccessibilityWizardView()
        .environmentObject(PermissionChecker())
}
