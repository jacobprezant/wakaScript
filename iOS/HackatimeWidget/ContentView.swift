//
//  ContentView.swift
//  HackatimeWidget
//
//  Created by Jacob on 6/27/25.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @AppStorage("hackatime_api_key", store: UserDefaults(suiteName: "group.hackatime")) private var apiKey: String = ""
    @State private var tempKey: String = ""
    @State private var userTime: String = "Loading..."
    @State private var timer: Timer?

    var body: some View {
        Group {
            if apiKey.isEmpty {
                VStack(spacing: 20) {
                    Text("Enter your Hackatime API Key")
                        .font(.headline)
                    SecureField("API Key", text: $tempKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Button("Save API Key") {
                        apiKey = tempKey
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .onAppear { tempKey = "" }
            } else {
                ZStack(alignment: .topLeading) {
                    ARViewContainer(textString: userTime)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            fetchAndSchedule()
                        }
                        .onDisappear {
                            timer?.invalidate()
                        }
                    Button(action: {
                        apiKey = ""
                        tempKey = ""
                        timer?.invalidate()
                    }) {
                        Image(systemName: "arrow.backward.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
            }
        }
    }

    func fetchAndSchedule() {
        fetchUserTime { time in
            userTime = time
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            fetchUserTime { time in
                userTime = time
            }
        }
    }

    func fetchUserTime(completion: @escaping (String) -> Void) {
        guard !apiKey.isEmpty else {
            completion("No API Key")
            return
        }
        let url = URL(string: "https://hackatime.hackclub.com/api/hackatime/v1/users/current/statusbar/today")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, _, _ in
            var userTime = "No/Bad Data"
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               let grandTotal = dataDict["grand_total"] as? [String: Any],
               let text = grandTotal["text"] as? String {
                userTime = text
            }
            DispatchQueue.main.async {
                completion(userTime)
            }
        }.resume()
    }
}

struct ARViewContainer: UIViewRepresentable {
    let textString: String

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let textAnchor = AnchorEntity()
        textAnchor.addChild(textGen(textString: textString))
        arView.scene.addAnchor(textAnchor)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        uiView.scene.anchors.removeAll()
        let textAnchor = AnchorEntity()
        textAnchor.addChild(textGen(textString: textString))
        uiView.scene.addAnchor(textAnchor)
    }

    func textGen(textString: String) -> ModelEntity {
        let material = SimpleMaterial(color: .black, roughness: 0, isMetallic: false)
        let depth: Float = 0.001
        let font = UIFont.systemFont(ofSize: 0.01)
        let containerFrame = CGRect(x: -0.05, y: -0.1, width: 0.1, height: 0.1)
        let alignment: CTTextAlignment = .center
        let lineBreakMode: CTLineBreakMode = .byWordWrapping
        let mesh = MeshResource.generateText(
            textString,
            extrusionDepth: depth,
            font: font,
            containerFrame: containerFrame,
            alignment: alignment,
            lineBreakMode: lineBreakMode
        )
        return ModelEntity(mesh: mesh, materials: [material])
    }
}


#Preview {
    ContentView()
}
