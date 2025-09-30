//
//  DataModel.swift
//  ExportKitDemo
//
//  Created by kent.sun on 2025/9/30.
//

import Foundation

struct SalesRecord: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let product: String
    let quantity: Int
    let price: Double
    let customer: String
    let region: String
    
    var total: Double {
        return Double(quantity) * price
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var formattedDate: String {
        Self.dateFormatter.string(from: date)
    }
}

class SalesDataManager: ObservableObject {
    @Published var salesRecords: [SalesRecord] = []
    
    init() {
        generateSampleData()
    }
    
    private func generateSampleData() {
        let products = ["iPhone 15", "MacBook Pro", "iPad Air", "Apple Watch", "AirPods Pro"]
        let customers = ["Tech Corp", "StartupXYZ", "Enterprise Ltd", "Innovation Inc", "Digital Solutions"]
        let regions = ["North America", "Europe", "Asia Pacific", "South America", "Middle East"]
        
        salesRecords = (1...20).map { index in
            let daysAgo = Int.random(in: 0...90)
            let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            
            return SalesRecord(
                date: date,
                product: products.randomElement() ?? "Unknown Product",
                quantity: Int.random(in: 1...10),
                price: Double.random(in: 100...3000).rounded(.toNearestOrAwayFromZero),
                customer: customers.randomElement() ?? "Unknown Customer",
                region: regions.randomElement() ?? "Unknown Region"
            )
        }.sorted { $0.date > $1.date }
    }
    
    func refreshData() {
        generateSampleData()
    }
    
    var totalSales: Double {
        salesRecords.reduce(0) { $0 + $1.total }
    }
    
    var totalQuantity: Int {
        salesRecords.reduce(0) { $0 + $1.quantity }
    }
}