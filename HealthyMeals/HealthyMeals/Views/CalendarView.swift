import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: MealTrackerViewModel
    @State private var selectedDate = Date()
    @State private var showingAddEntry = false
    
    private var entriesForSelectedDate: [DailyMealEntry] {
        viewModel.dailyEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    private var totalCalories: Double {
        entriesForSelectedDate.reduce(0) { $0 + $1.totalCalories }
    }
    
    private var totalProtein: Double {
        entriesForSelectedDate.reduce(0) { $0 + $1.totalProtein }
    }
    
    private var totalFat: Double {
        entriesForSelectedDate.reduce(0) { $0 + $1.totalFat }
    }
    
    private var totalCarbs: Double {
        entriesForSelectedDate.reduce(0) { $0 + $1.totalCarbs }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                List {
                    Section(header: Text("Daily Summary")) {
                        HStack {
                            Text("Total Calories:")
                            Spacer()
                            Text("\(Int(totalCalories))")
                        }
                        HStack {
                            Text("Total Protein:")
                            Spacer()
                            Text("\(Int(totalProtein))g")
                        }
                        HStack {
                            Text("Total Fat:")
                            Spacer()
                            Text("\(Int(totalFat))g")
                        }
                        HStack {
                            Text("Total Carbs:")
                            Spacer()
                            Text("\(Int(totalCarbs))g")
                        }
                    }
                    
                    Section(header: Text("Meals")) {
                        ForEach(entriesForSelectedDate) { entry in
                            VStack(alignment: .leading) {
                                Text(entry.referenceMeal.name)
                                    .font(.headline)
                                HStack {
                                    Text("Portions: \(String(format: "%.1f", entry.portions))")
                                    Spacer()
                                    Text("Calories: \(Int(entry.totalCalories))")
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            let entriesToDelete = indexSet.map { entriesForSelectedDate[$0] }
                            for entry in entriesToDelete {
                                if let index = viewModel.dailyEntries.firstIndex(where: { $0.id == entry.id }) {
                                    viewModel.dailyEntries.remove(at: index)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Meal Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEntry = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddDailyEntryView(viewModel: viewModel, selectedDate: selectedDate)
            }
        }
    }
}

struct AddDailyEntryView: View {
    @ObservedObject var viewModel: MealTrackerViewModel
    let selectedDate: Date
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedMeal: ReferenceMeal?
    @State private var portions = ""
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Select Meal", selection: $selectedMeal) {
                    Text("Select a meal").tag(nil as ReferenceMeal?)
                    ForEach(viewModel.referenceMeals) { meal in
                        Text(meal.name).tag(meal as ReferenceMeal?)
                    }
                }
                
                TextField("Portions", text: $portions)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add Meal Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let meal = selectedMeal,
                           let portionsValue = Double(portions) {
                            let entry = DailyMealEntry(
                                date: selectedDate,
                                referenceMeal: meal,
                                portions: portionsValue
                            )
                            viewModel.addDailyEntry(entry)
                            dismiss()
                        }
                    }
                    .disabled(selectedMeal == nil || portions.isEmpty)
                }
            }
        }
    }
} 