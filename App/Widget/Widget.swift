//
//  Widget.swift
//  Widget
//
//  Created by Higashihara Yoki on 2022/09/30.
//

import WidgetKit
import SwiftUI

import WidgetFeature

@main
struct SanpoWidget: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Sanpo")
        .supportedFamilies([.accessoryCircular])
    }
}
