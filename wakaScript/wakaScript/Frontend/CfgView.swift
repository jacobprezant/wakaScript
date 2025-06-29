//
//  CfgView.swift
//  wakaScript
//
//  Created by Jacob on 6/18/25.
//

import SwiftUI

struct CfgView: View {
    @State private var step = 1
    @State private var showURLInfo = false
    @State private var showKeyInfo = false
    @State private var URLtext = ""
    @State private var button1Pressed = false
    @State private var button2Pressed = false
    @State private var KEYtext = ""
    var onConfigWritten: (() -> Void)? = nil
    
    var isValidURL: Bool {
            if let url = URL(string: URLtext), url.scheme != nil, url.host != nil {
                return true
            }
            return false
        }
    
    var showFinalButton: Bool {
        !URLtext.isEmpty || button1Pressed || button2Pressed
    }
    
    var body: some View {
        VStack(spacing: 20) {
            switch step {
            case 1:
                Text("This is a quick wizard for getting your `~/.wakatime.cfg` file set up. It's essentially your settings file.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                Text("You've been brought here because wakaScript looked and couldn't find yours, or you decided to change your settings. It's time to set it up!")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                    //.multilineTextAlignment(.center)
                Text("We really only need two things:")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Text("your API URL")
                    Button(action: { showURLInfo = true }) {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .popover(isPresented: $showURLInfo) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("A URL is a link, or server, that is prepared to accept the requests that WakaTime sends. This can be either WakaTime's official API for use with their dashboard, or another service based off of WakaTime; like Hackatime.")
                            Text("If you don't know what this is and are just using WakaTime.com, don't worry.")
                            Button("Close") { showURLInfo = false }
                                .padding(.top)
                        }
                        .padding()
                        .frame(width: 300)
                    }
                }
                HStack {
                    Text("your API Key")
                    Button(action: { showKeyInfo = true }) {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .popover(isPresented: $showKeyInfo) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your API key is the most important part. It's what tells the server who you are, and who to associate your coding time with.")
                            Text("You'll need to get one from your alternate service provider, like Hackatime, or from WakaTime [here](https://wakatime.com/api-key).")
                            Text("But we'll talk more about this later.")
                            Button("Close") { showKeyInfo = false }
                                .padding(.top)
                        }
                        .padding()
                        .frame(width: 300)
                    }
                }
                Button("Ready to get started? Let's go!"){
                    step = 2
                }
            case 2:
                Text("Okay; you'll need to either select your API's URL from the two most common below, or enter it yourself. If you don't know what this is, just select the official WakaTime.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                        Button("Hackatime"){
                            URLtext = "https://hackatime.hackclub.com/api/hackatime/v1"
                            button1Pressed = true
                            button2Pressed = false
                        }
                                Button("WakaTime"){
                            URLtext = "https://api.wakatime.com/api/v1/"
                            button2Pressed = true
                            button1Pressed = false
                        }
                    }
                
                
                TextField("Enter your WakaTime compatible API URL", text: $URLtext)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .frame(maxWidth: 320)
                            .fixedSize(horizontal: false, vertical: true)
                if showFinalButton && isValidURL {
                    Button("Great! I have my API URL now.") {
                        step = 3
                    }
                } else if showFinalButton && !isValidURL {
                    Text("Make sure to enter a valid API URL. The URL you entered is invalid.")
                        .frame(maxWidth: 320)
                        .fixedSize(horizontal: false, vertical: true)
                }
            case 3:
                Text("Now, you'll need to set up your API key. You will either have this given to you by your alternate service provider, like Hackatime, or you can [grab your official WakaTime API key here](https://wakatime.com/api-key).")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                Text("An API key is what tells the server who you are, and ties your time to your account.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                TextField("Go ahead and paste your API key here", text: $KEYtext)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .frame(maxWidth: 320)
                            .fixedSize(horizontal: false, vertical: true)
                if !KEYtext.isEmpty {
                    Button("Great! WakaScript has your API key and URL.") {
                        step = 4
                    }
                }
            case 4:
                Image(systemName: "hand.thumbsup.fill")
                    .font(.system(size: 50))
                Text("You're good to go. Now, you can start using WakaScript! If you ever need to change these settings, you can always come back.")
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Let's get to scripting!") {
                    writeWakatimeConfig(urlText: URLtext, keyText: KEYtext)
                    onConfigWritten?()
                    step = 100
                }
        
            default:
                EmptyView()
        }
    }
    .padding(.bottom, 40)
    .frame(width: 400, height: 400)
        }
    }


#Preview {
    CfgView()
}
