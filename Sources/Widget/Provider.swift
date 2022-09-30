import WidgetKit
import SwiftUI

public struct Provider: TimelineProvider {

    public init() {}

    public func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    public func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

public struct SimpleEntry: TimelineEntry {
    public let date: Date

    public init(date: Date) {
        self.date = date
    }
}

public struct WidgetEntryView: View {
    var entry: Provider.Entry

    public init(entry: Provider.Entry) {
        self.entry = entry
    }

    public var body: some View {
        Text(entry.date, style: .time)
    }
}
