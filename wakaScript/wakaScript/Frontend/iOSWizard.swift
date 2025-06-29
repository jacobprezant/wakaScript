//
//  iOSWizard.swift
//  wakaScript
//
//  Created by Jacob on 6/28/25.
//

import SwiftUI

struct iOSWizard: View {
    @State private var numberText = ""
    @State private var isSent = "false"
    
    // Computed property to check if input is exactly 10 digits
    var isValidNumber: Bool {
        let digitsOnly = numberText.allSatisfy { $0.isNumber }
        return digitsOnly && numberText.count == 10
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text("This will send an SMS to your phone number with a TestFlight link where you can install an app on your iOS device with a home screen widget displaying your daily Waka/Hackatime time.")
                .padding(.horizontal, 10)
            Text("This app is open-source, as is wakaScript, and can be found within the [WakaScript repository](https://github.com/jacobprezant/wakaScript) on GitHub.")
                .padding(.horizontal, 10)
            TextField("Enter your phone number", text: $numberText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(maxWidth: 320)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("No spaces or special characters, just numbers. Only US numbers are accepted currently. Please don't abuse this. This is free software.")
                .padding(.horizontal, 10)
            if isSent == "false" {
                if isValidNumber {
                    Button("Send SMS") {
                        isSent = "true"
                    }
                    .padding(.top)
                }
            }
            if isSent == "true" {
                Text("SMS sent!")
            }
        }
        .frame(width: 240, height: 330, alignment: .center)
    }
}

#Preview {
    iOSWizard()
}
