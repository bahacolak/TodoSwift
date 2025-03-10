import Foundation
import SwiftData

@Model
class Medication {
    var name: String
    var dosage: String
    var frequency: String
    var startDate: Date
    var endDate: Date?
    var notes: String?
    var reminder: Bool
    var timeOfDay: [TimeOfDay]
    var stock: Int?
    var stockAlert: Int?
    var isActive: Bool
    
    init(
        name: String,
        dosage: String,
        frequency: String,
        startDate: Date,
        timeOfDay: [TimeOfDay] = [],
        notes: String? = nil,
        reminder: Bool = true,
        stock: Int? = nil,
        stockAlert: Int? = nil
    ) {
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.startDate = startDate
        self.timeOfDay = timeOfDay
        self.notes = notes
        self.reminder = reminder
        self.stock = stock
        self.stockAlert = stockAlert
        self.isActive = true
    }
}

enum TimeOfDay: String, Codable, CaseIterable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case bedtime = "Bedtime"
    
    var icon: String {
        switch self {
        case .morning:
            return "sunrise.fill"
        case .afternoon:
            return "sun.max.fill"
        case .evening:
            return "sunset.fill"
        case .bedtime:
            return "moon.fill"
        }
    }
    
    var time: Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .morning:
            return calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now
        case .afternoon:
            return calendar.date(bySettingHour: 13, minute: 0, second: 0, of: now) ?? now
        case .evening:
            return calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now
        case .bedtime:
            return calendar.date(bySettingHour: 22, minute: 0, second: 0, of: now) ?? now
        }
    }
} 