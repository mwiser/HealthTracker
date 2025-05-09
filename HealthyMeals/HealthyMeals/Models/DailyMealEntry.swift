import Foundation

struct DailyMealEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let referenceMeal: ReferenceMeal
    var portions: Double
    
    init(id: UUID = UUID(), date: Date, referenceMeal: ReferenceMeal, portions: Double) {
        self.id = id
        self.date = date
        self.referenceMeal = referenceMeal
        self.portions = portions
    }
    
    var totalCalories: Double {
        referenceMeal.calories * portions
    }
    
    var totalProtein: Double {
        referenceMeal.protein * portions
    }
    
    var totalFat: Double {
        referenceMeal.fat * portions
    }
    
    var totalCarbs: Double {
        referenceMeal.carbs * portions
    }
} 