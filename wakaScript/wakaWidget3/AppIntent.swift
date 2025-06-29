//
//  AppIntent.swift
//  wakaWidget3
//
//  Created by Jacob on 6/28/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "Widget that shows daily Hackatime time." }

    @Parameter(title: "Sample Param", default: "Hello")
    var sampleParam: String
}
