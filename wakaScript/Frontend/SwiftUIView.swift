//
//  SwiftUIView.swift
//  wakaScript
//
//  Created by Jacob on 6/26/25.
//

import SwiftUI

struct SwiftUIView: View {
    @State private var settings = false
    @State private var scripting = false
    @State private var social = false
    @State private var starter = true
    
    @AppStorage("isPrivacy") private var isPrivacy: String = "false"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("applescript-wakatime")
                    .font(.system(size: 30, design: .monospaced))
                    .bold()
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 20)
            }
            HStack {
                Button(action: {
                    settings = true
                    scripting = false
                    social = false
                    starter = false
                }) {
                    Image(systemName: "gear")
                        .font(.system(size: 30))
                        .padding(.horizontal, 25)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    settings = false
                    scripting = true
                    social = false
                    starter = false
                }) {
                    Image(systemName: "applescript")
                        .font(.system(size: 30))
                        .padding(.horizontal, 25)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    settings = false
                    scripting = false
                    social = true
                    starter = false
                }) {
                    Image(systemName: "message")
                        .font(.system(size: 30))
                        .padding(.horizontal, 25)
                }
                .buttonStyle(.plain)
            }
                if settings == true {
                    NavigationLink("Reconfigure API URL and Key") {
                        CfgView()
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                    NavigationLink("Reconfigure accessibility permissions") {
                        AccessibilityWizardView()
                    }
                }
            if scripting == true {
                if isPrivacy == "false" {
                    Button("Enable file path obfuscation") {
                        appendHideProjectFolderSetting()
                        isPrivacy = "true"
                    }
                    .padding(.top, 20)
                }
                if isPrivacy == "true"
                    {
                    Button("Disable file path obfuscation") {
                        appendShowProjectFolderSetting()
                        isPrivacy = "false"
                    }
                    .padding(.top, 20)
                }
                
                
            }
            }
            //.padding(.bottom, 40)
            .frame(width: 400, height: 400, alignment: .center)
        
    }
}

#Preview {
    SwiftUIView()
}
