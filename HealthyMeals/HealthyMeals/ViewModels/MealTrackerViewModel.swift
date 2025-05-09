import Foundation
import SwiftUI

@MainActor
class MealTrackerViewModel: ObservableObject {
    @Published var referenceMeals: [ReferenceMeal] = []
    @Published var dailyEntries: [DailyMealEntry] = []
    
    private let referenceMealsKey = "referenceMeals"
    private let dailyEntriesKey = "dailyEntries"
    
    init() {
        loadData()
    }
    
    func addReferenceMeal(_ meal: ReferenceMeal) {
        referenceMeals.append(meal)
        saveData()
    }
    
    func addDailyEntry(_ entry: DailyMealEntry) {
        dailyEntries.append(entry)
        saveData()
    }
    
    func removeReferenceMeal(at indexSet: IndexSet) {
        referenceMeals.remove(atOffsets: indexSet)
        saveData()
    }
    
    func removeDailyEntry(at indexSet: IndexSet) {
        dailyEntries.remove(atOffsets: indexSet)
        saveData()
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(referenceMeals) {
            UserDefaults.standard.set(encoded, forKey: referenceMealsKey)
        }
        if let encoded = try? JSONEncoder().encode(dailyEntries) {
            UserDefaults.standard.set(encoded, forKey: dailyEntriesKey)
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: referenceMealsKey),
           let decoded = try? JSONDecoder().decode([ReferenceMeal].self, from: data) {
            referenceMeals = decoded
        }
        if let data = UserDefaults.standard.data(forKey: dailyEntriesKey),
           let decoded = try? JSONDecoder().decode([DailyMealEntry].self, from: data) {
            dailyEntries = decoded
        }
    }
    
    func exportToCSV() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        var csvString = "Date,Food Name,Calories,Protein,Fat,Carbs\n"
        
        for entry in dailyEntries.sorted(by: { $0.date < $1.date }) {
            let row = [
                dateFormatter.string(from: entry.date),
                entry.referenceMeal.name,
                String(format: "%.1f", entry.totalCalories),
                String(format: "%.1f", entry.totalProtein),
                String(format: "%.1f", entry.totalFat),
                String(format: "%.1f", entry.totalCarbs)
            ].joined(separator: ",")
            csvString.append(row + "\n")
        }
        
        return csvString
    }
} 