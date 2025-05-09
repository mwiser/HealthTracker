import SwiftUI

struct ReferenceMealsView: View {
    @ObservedObject var viewModel: MealTrackerViewModel
    @State private var showingAddMeal = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.referenceMeals) { meal in
                    VStack(alignment: .leading) {
                        Text(meal.name)
                            .font(.headline)
                        HStack {
                            Text("Calories: \(Int(meal.calories))")
                            Spacer()
                            Text("Protein: \(Int(meal.protein))g")
                            Spacer()
                            Text("Fat: \(Int(meal.fat))g")
                            Spacer()
                            Text("Carbs: \(Int(meal.carbs))g")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: viewModel.removeReferenceMeal)
            }
            .navigationTitle("Reference Meals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMeal = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMeal) {
                AddReferenceMealView(viewModel: viewModel)
            }
        }
    }
}

struct AddReferenceMealView: View {
    @ObservedObject var viewModel: MealTrackerViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var fat = ""
    @State private var carbs = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Meal Name", text: $name)
                TextField("Calories", text: $calories)
                    .keyboardType(.decimalPad)
                TextField("Protein (g)", text: $protein)
                    .keyboardType(.decimalPad)
                TextField("Fat (g)", text: $fat)
                    .keyboardType(.decimalPad)
                TextField("Carbs (g)", text: $carbs)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add Reference Meal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let caloriesValue = Double(calories),
                           let proteinValue = Double(protein),
                           let fatValue = Double(fat),
                           let carbsValue = Double(carbs) {
                            let meal = ReferenceMeal(
                                name: name,
                                calories: caloriesValue,
                                protein: proteinValue,
                                fat: fatValue,
                                carbs: carbsValue
                            )
                            viewModel.addReferenceMeal(meal)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || calories.isEmpty || protein.isEmpty || fat.isEmpty || carbs.isEmpty)
                }
            }
        }
    }
} 