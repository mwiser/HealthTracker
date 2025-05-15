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
    
    func importReferenceMealsFromCSV(_ csvString: String) {
        let rows = csvString.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map { $0.components(separatedBy: ",") }
        
        // Skip header row if it exists
        let startIndex = rows.first?.contains("Name") == true ? 1 : 0
        
        for row in rows[startIndex...] {
            guard row.count >= 5,
                  let calories = Double(row[1].trimmingCharacters(in: .whitespaces)),
                  let protein = Double(row[2].trimmingCharacters(in: .whitespaces)),
                  let fat = Double(row[3].trimmingCharacters(in: .whitespaces)),
                  let carbs = Double(row[4].trimmingCharacters(in: .whitespaces)) else {
                continue
            }
            
            let meal = ReferenceMeal(
                name: row[0].trimmingCharacters(in: .whitespaces),
                calories: calories,
                protein: protein,
                fat: fat,
                carbs: carbs
            )
            addReferenceMeal(meal)
        }
    }
} 