import SwiftUI
import WidgetKit

public struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily

    var entry: Provider.Entry

    public init(entry: Provider.Entry) {
        self.entry = entry
    }

    public var body: some View {
        VStack {
            switch family {
            case .systemSmall:
                WidgetSmallView(entry: entry)
            case .accessoryCircular:
                WidgetCircularView(entry: entry)
            default:
                fatalError("Not implemented")
            }
        }.onAppear {
            print(family)
        }
    }
}

private struct WidgetSmallView: View {

    var entry: Provider.Entry

    public init(entry: Provider.Entry) {
        self.entry = entry
    }

    public var body: some View {
        Text("\(entry.todayStepCount)")
    }
}

private struct WidgetCircularView: View {

    var entry: Provider.Entry

    public init(entry: Provider.Entry) {
        self.entry = entry
    }

    public var body: some View {
        Text("\(entry.todayStepCount)")
    }
}
