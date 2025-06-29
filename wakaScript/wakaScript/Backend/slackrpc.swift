//
//  slackrpc.swift
//  wakaScript
//
//  Created by Jacob on 6/19/25.
//

import Foundation

//the function to update status on stack (appends an emoji)
func updateSlackStatus(token: String, status: String) {
    let s = status + " 🚀"
    var r = URLRequest(url: URL(string: "https://slack.com/api/users.profile.set")!)
    r.httpMethod = "POST"
    r.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    r.addValue("application/json", forHTTPHeaderField: "Content-Type")
    r.httpBody = try? JSONSerialization.data(withJSONObject: ["profile": ["status_text": s]])
    URLSession.shared.dataTask(with: r).resume()
}

///sample call
///updateSlackStatus(token: "xoxp-abc-defg", status: "Locked in on \(script)")
