//
//  SwiftUIView.swift
//  wakaScript
//
//  Created by Jacob on 6/26/25.
//

import SwiftUI

enum TabSelection {
    case none, settings, scripting, social
}

struct InfoButton: View {
    @Binding var show: Bool
    var body: some View {
        Button(action: { show = true }) {
            Image(systemName: "info.circle")
        }
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $show) {
            VStack(alignment: .leading, spacing: 12) {
                Text("What's Open-Source ?")
                    .font(.headline)
                Text("wakaScript is fully open-source. Anyone—including you—can inspect the code to verify exactly what it does, making it transparent and safe to use.")
                Text("Give wakaScript a ") +
                Text(Image(systemName: "star.fill"))
                    .foregroundColor(.yellow)
                + Text(" on GitHub if you found it useful!")
                Link("View on GitHub", destination: URL(string: "https://github.com/jacobprezant/wakaScript")!)
                Button("Close") { show = false }
                    .padding(.top)
            }
            .padding()
            .frame(width: 300)
        }
    }
}

struct SwiftUIView: View {
    @State private var showOpenSourceInfo = false
    @State private var selectedTab: TabSelection = .none
    @AppStorage("isPrivacy") private var isPrivacy: String = "false"
    @AppStorage("isTracking") private var isTracking: String = "false"
    @AppStorage("debugEnabled") private var debugEnabled: String = "false"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("wakaScript")
                    .font(.system(size: 35, design: .monospaced))
                    .bold()
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 20)
                
                HStack {
                    Button(action: {
                        selectedTab = (selectedTab == .settings) ? .none : .settings
                    }) {
                        Image(systemName: "gear")
                            .font(.system(size: 30))
                            .padding(.horizontal, 25)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        selectedTab = (selectedTab == .scripting) ? .none : .scripting
                    }) {
                        Image(systemName: "applescript")
                            .font(.system(size: 30))
                            .padding(.horizontal, 25)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        selectedTab = (selectedTab == .social) ? .none : .social
                    }) {
                        Image(systemName: "message")
                            .font(.system(size: 30))
                            .padding(.horizontal, 25)
                    }
                    .buttonStyle(.plain)
                }
                
                if selectedTab == .settings {
                    NavigationLink("Reconfigure API URL and key") {
                        CfgView()
                    }
                    .padding(.top, 10)
                    NavigationLink("Reconfigure accessibility permissions") {
                        AccessibilityWizardView()
                    }
                    if debugEnabled == "false" {
                        Button("Enable verbose logging and sending diagnostics to WakaTime") {
                            debugEnabled = "true"
                        }
                    }
                    if debugEnabled == "true" {
                        Button("Disable verbose logging and sending diagnostics to WakaTime") {
                            debugEnabled = "false"
                        }
                    }
                    Text("Experiments:")
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .font(.system(size: 14, weight: .bold))
                    NavigationLink("Run script and send completion notification via [ntfy.sh](https://ntfy.sh)") {
                        //ntfyWizard()
                    }
                    NavigationLink("Walk me through adding a daily time widget to the desktop") {
                        //widgetWizard()
                    }
                    NavigationLink("Text me a link for an iOS daily time widget") {
                        iOSWizard()
                            .background(.ultraThinMaterial)
                            .transparentWindow()
                            .hideZoomButton()
                    }
                }
                
                if selectedTab == .scripting {
                    if isPrivacy == "false" {
                        Button("Enable relative file path obfuscation") {
                            appendHideProjectFolderSetting()
                            isPrivacy = "true"
                        }
                        .padding(.top, 20)
                    }
                    if isPrivacy == "true" {
                        Button("Disable relative file path obfuscation") {
                            appendShowProjectFolderSetting()
                            isPrivacy = "false"
                        }
                        .padding(.top, 20)
                    }
                    Button("Set alternate project name") {
                        //alternateProjectView()
                    }
                    if isTracking == "false" {
                        Button(action: {
                            //appendincludeonlywithprojectFile()
                            isTracking = "true"
                        }) {
                            Text("Turn off tracking for projects that haven't been explicitly enabled")
                            //.multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            //.frame(maxWidth: 320)
                            //.padding(.horizontal, 16)
                        }
                    }
                    if isTracking == "true" {
                        Button(action: {
                            //DisableincludeonlywithprojectFile()
                            isTracking = "false"
                        }) {
                            Text("Turn on tracking for projects that haven't been explicitly enabled")
                            //.multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            //.frame(maxWidth: 320)
                            //.padding(.horizontal, 16)
                        }
                        Button(action: {
                            //explictTrackingView()
                        }) {
                            Text("Manage explicitly enabled projects")
                            //.multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            //.frame(maxWidth: 320)
                            //.padding(.horizontal, 16)
                        }
                    }
                }
                if selectedTab == .none {
                    HStack {
                        Text("wakaScript is open-source")
                            .padding(.top, 20)
                        InfoButton(show: $showOpenSourceInfo)
                            .padding(.top, 20)
                    }
                }
            }
        }
            .frame(width: 450, height: 450, alignment: .center)
        }
    }

#Preview {
    SwiftUIView()
        .environmentObject(PermissionChecker())
}
