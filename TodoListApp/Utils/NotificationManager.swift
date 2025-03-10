import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleMedicationReminder(for medication: Medication) {
        guard medication.reminder else { return }
        
        // Remove existing notifications for this medication
        removeMedicationReminders(for: medication)
        
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "Time to take \(medication.name) - \(medication.dosage)"
        content.sound = .default
        
        // Schedule notifications for each time of day
        for timeOfDay in medication.timeOfDay {
            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: timeOfDay.time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(
                identifier: "medication-\(medication.name)-\(timeOfDay.rawValue)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func removeMedicationReminders(for medication: Medication) {
        let identifiers = medication.timeOfDay.map { "medication-\(medication.name)-\($0.rawValue)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func scheduleStockAlert(for medication: Medication) {
        guard let stock = medication.stock,
              let alert = medication.stockAlert,
              stock <= alert else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Low Medication Stock"
        content.body = "Your \(medication.name) stock is running low (\(stock) remaining)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "stock-alert-\(medication.name)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
} 