import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: MealTrackerViewModel
    @State private var selectedDate = Date()
    @State private var showingAddEntry = false
    @State private var selectedEntry: DailyMealEntry?
    
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
            ScrollView {
                VStack(spacing: 0) {
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    
                    VStack(spacing: 16) {
                        // Daily Summary Card
                        VStack(spacing: 12) {
                            Text("Daily Summary")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                SummaryRow(title: "Total Calories", value: "\(Int(totalCalories))")
                                SummaryRow(title: "Total Protein", value: "\(Int(totalProtein))g")
                                SummaryRow(title: "Total Fat", value: "\(Int(totalFat))g")
                                SummaryRow(title: "Total Carbs", value: "\(Int(totalCarbs))g")
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        
                        // Meals List
                        VStack(spacing: 12) {
                            Text("Meals")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if entriesForSelectedDate.isEmpty {
                                Text("No meals added for this day")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(entriesForSelectedDate) { entry in
                                    Button(action: {
                                        selectedEntry = entry
                                    }) {
                                        MealEntryRow(entry: entry)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 1)
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
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
            .sheet(item: $selectedEntry) { entry in
                MealEntryDetailView(viewModel: viewModel, entry: entry)
            }
        }
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

struct MealEntryRow: View {
    let entry: DailyMealEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.referenceMeal.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Text("Portions: \(String(format: "%.1f", entry.portions))")
                Spacer()
                Text("Calories: \(Int(entry.totalCalories))")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

struct MealEntryDetailView: View {
    @ObservedObject var viewModel: MealTrackerViewModel
    let entry: DailyMealEntry
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Meal Details")) {
                    LabeledContent("Name", value: entry.referenceMeal.name)
                    LabeledContent("Portions", value: String(format: "%.1f", entry.portions))
                }
                
                Section(header: Text("Nutritional Information")) {
                    LabeledContent("Calories", value: "\(Int(entry.totalCalories))")
                    LabeledContent("Protein", value: "\(Int(entry.totalProtein))g")
                    LabeledContent("Fat", value: "\(Int(entry.totalFat))g")
                    LabeledContent("Carbs", value: "\(Int(entry.totalCarbs))g")
                }
                
                Section {
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Delete Entry")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Meal Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Entry", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let index = viewModel.dailyEntries.firstIndex(where: { $0.id == entry.id }) {
                        viewModel.dailyEntries.remove(at: index)
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to delete this meal entry?")
            }
        }
    }
}

struct AddDailyEntryView: View {
    @ObservedObject var viewModel: MealTrackerViewModel
    let selectedDate: Date
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedMeal: ReferenceMeal?
    @State private var searchText = ""
    @State private var portions: Double = 1.0
    @State private var isAdHocMode = false
    @State private var adHocName = ""
    @State private var adHocCalories = ""
    @State private var adHocProtein = ""
    
    private var filteredMeals: [ReferenceMeal] {
        if searchText.isEmpty {
            return viewModel.referenceMeals
        } else {
            return viewModel.referenceMeals.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private let portionOptions: [Double] = [0.5, 1.0, 1.5, 2.0, 3.0]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Meal Type", selection: $isAdHocMode) {
                        Text("Reference Meal").tag(false)
                        Text("Ad-hoc Meal").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if isAdHocMode {
                    Section(header: Text("Ad-hoc Meal Details")) {
                        TextField("Meal Name", text: $adHocName)
                        TextField("Calories (optional)", text: $adHocCalories)
                            .keyboardType(.decimalPad)
                        TextField("Protein (g) (optional)", text: $adHocProtein)
                            .keyboardType(.decimalPad)
                    }
                } else {
                    Section(header: Text("Select Meal")) {
                        TextField("Search meals...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if !filteredMeals.isEmpty {
                            ForEach(filteredMeals) { meal in
                                Button(action: {
                                    selectedMeal = meal
                                }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(meal.name)
                                                .foregroundColor(.primary)
                                            Text("\(Int(meal.calories)) cal • \(Int(meal.protein))g protein • \(Int(meal.fat))g fat • \(Int(meal.carbs))g carbs")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        if selectedMeal?.id == meal.id {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        } else {
                            Text("No meals found")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Portions")) {
                    VStack {
                        Picker("Portions", selection: $portions) {
                            ForEach(portionOptions, id: \.self) { portion in
                                Text(String(format: "%.1f", portion))
                                    .tag(portion)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Text("Selected: \(String(format: "%.1f", portions)) portions")
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
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
                        if isAdHocMode {
                            let calories = Double(adHocCalories) ?? 0
                            let protein = Double(adHocProtein) ?? 0
                            let adHocMeal = ReferenceMeal(
                                name: adHocName,
                                calories: calories,
                                protein: protein,
                                fat: 0,
                                carbs: 0
                            )
                            let entry = DailyMealEntry(
                                date: selectedDate,
                                referenceMeal: adHocMeal,
                                portions: portions
                            )
                            viewModel.addDailyEntry(entry)
                            dismiss()
                        } else if let meal = selectedMeal {
                            let entry = DailyMealEntry(
                                date: selectedDate,
                                referenceMeal: meal,
                                portions: portions
                            )
                            viewModel.addDailyEntry(entry)
                            dismiss()
                        }
                    }
                    .disabled((isAdHocMode && adHocName.isEmpty) || (!isAdHocMode && selectedMeal == nil))
                }
            }
        }
    }
} 