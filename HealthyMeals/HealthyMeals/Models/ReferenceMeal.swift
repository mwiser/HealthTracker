import Foundation

struct ReferenceMeal: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var calories: Double
    var protein: Double
    var fat: Double
    var carbs: Double
    
    init(id: UUID = UUID(), name: String, calories: Double, protein: Double, fat: Double, carbs: Double) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ReferenceMeal, rhs: ReferenceMeal) -> Bool {
        lhs.id == rhs.id
    }
} 