import SwiftUI
import UniformTypeIdentifiers

struct ReferenceMealsView: View {
    @ObservedObject var viewModel: MealTrackerViewModel
    @State private var showingAddMeal = false
    @State private var showingImportSheet = false
    @State private var showingImportError = false
    @State private var importError: String = ""
    
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
                    Menu {
                        Button(action: { showingAddMeal = true }) {
                            Label("Add Meal", systemImage: "plus")
                        }
                        Button(action: { showingImportSheet = true }) {
                            Label("Import CSV", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMeal) {
                AddReferenceMealView(viewModel: viewModel)
            }
            .fileImporter(
                isPresented: $showingImportSheet,
                allowedContentTypes: [UTType.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let files):
                    guard let selectedFile = files.first else { return }
                    
                    if selectedFile.startAccessingSecurityScopedResource() {
                        defer { selectedFile.stopAccessingSecurityScopedResource() }
                        
                        do {
                            let csvString = try String(contentsOf: selectedFile, encoding: .utf8)
                            viewModel.importReferenceMealsFromCSV(csvString)
                        } catch {
                            importError = "Failed to read file: \(error.localizedDescription)"
                            showingImportError = true
                        }
                    }
                case .failure(let error):
                    importError = "Failed to import file: \(error.localizedDescription)"
                    showingImportError = true
                }
            }
            .alert("Import Error", isPresented: $showingImportError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(importError)
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