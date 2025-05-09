//
//  HealthyMealsApp.swift
//  HealthyMeals
//
//  Created by Martin Wiser on 5/9/25.
//

import SwiftUI

@main
struct HealthyMealsApp: App {
    @StateObject private var viewModel = MealTrackerViewModel()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                CalendarView(viewModel: viewModel)
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                
                ReferenceMealsView(viewModel: viewModel)
                    .tabItem {
                        Label("Meals", systemImage: "list.bullet")
                    }
                
                ExportView(viewModel: viewModel)
                    .tabItem {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
            }
        }
    }
}

struct ExportView: View {
    @ObservedObject var viewModel: MealTrackerViewModel
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Export your meal tracking data to CSV format")
                    .padding()
                
                Button(action: {
                    showingShareSheet = true
                }) {
                    Label("Export to CSV", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Export Data")
            .sheet(isPresented: $showingShareSheet) {
                if let csvData = viewModel.exportToCSV().data(using: .utf8) {
                    ShareSheet(items: [csvData])
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
