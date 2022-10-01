import Foundation

public extension Calendar {
    func array(from startDate: Date, to endDate: Date) -> [DateComponents] {
        var result: [DateComponents] = []

        let diff = dateComponents([.day], from: startDate, to: endDate).day ?? 0
        for day in 0...diff {
            let date = date(byAdding: .day, value: day, to: startDate)!
            let item = dateComponents(in: .current, from: date)
            result.append(item)
        }

        return result
    }
}
