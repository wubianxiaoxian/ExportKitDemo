//
//  ContentView.swift
//  ExportKitDemo
//
//  Created by kent.sun on 2025/9/30.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var salesDataManager = SalesDataManager()
    @StateObject private var exportManager = ExportManager()
    
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var isExporting = false
    @State private var exportMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Export Kit Demo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("PDF • CSV • TXT Export with Share Sheet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Summary Cards
                HStack(spacing: 15) {
                    SummaryCard(
                        title: "Total Sales",
                        value: "$\(String(format: "%.2f", salesDataManager.totalSales))",
                        icon: "dollarsign.circle.fill",
                        color: .green
                    )
                    
                    SummaryCard(
                        title: "Records",
                        value: "\(salesDataManager.salesRecords.count)",
                        icon: "list.number",
                        color: .blue
                    )
                    
                    SummaryCard(
                        title: "Items Sold",
                        value: "\(salesDataManager.totalQuantity)",
                        icon: "cube.box.fill",
                        color: .orange
                    )
                }
                .padding(.horizontal)
                
                // Data Preview
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Recent Sales")
                            .font(.headline)
                        Spacer()
                        Button("Refresh") {
                            salesDataManager.refreshData()
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(salesDataManager.salesRecords.prefix(5)) { record in
                                SalesRowView(record: record)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
                .padding(.horizontal)
                
                // Export Buttons
                VStack(spacing: 12) {
                    Text("Export Options")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        ExportButton(
                            title: "PDF Report",
                            icon: "doc.fill",
                            color: .red,
                            isLoading: isExporting
                        ) {
                            exportToPDF()
                        }
                        
                        ExportButton(
                            title: "CSV Data",
                            icon: "tablecells.fill",
                            color: .green,
                            isLoading: isExporting
                        ) {
                            exportToCSV()
                        }
                        
                        ExportButton(
                            title: "TXT Report",
                            icon: "doc.text.fill",
                            color: .blue,
                            isLoading: isExporting
                        ) {
                            exportToTXT()
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: shareItems)
        }
        .alert("Export Status", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(exportMessage)
        }
    }
    
    // MARK: - Export Functions
    private func exportToPDF() {
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let pdfURL = exportManager.generatePDF(from: salesDataManager.salesRecords) {
                DispatchQueue.main.async {
                    self.shareItems = [ShareableFileItem(fileURL: pdfURL, title: "Sales Report PDF")]
                    self.showingShareSheet = true
                    self.isExporting = false
                }
            } else {
                DispatchQueue.main.async {
                    self.exportMessage = "Failed to generate PDF"
                    self.showingAlert = true
                    self.isExporting = false
                }
            }
        }
    }
    
    private func exportToCSV() {
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let csvURL = exportManager.generateCSV(from: salesDataManager.salesRecords) {
                DispatchQueue.main.async {
                    self.shareItems = [ShareableFileItem(fileURL: csvURL, title: "Sales Data CSV")]
                    self.showingShareSheet = true
                    self.isExporting = false
                }
            } else {
                DispatchQueue.main.async {
                    self.exportMessage = "Failed to generate CSV"
                    self.showingAlert = true
                    self.isExporting = false
                }
            }
        }
    }
    
    private func exportToTXT() {
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let txtURL = exportManager.generateTXT(from: salesDataManager.salesRecords) {
                DispatchQueue.main.async {
                    self.shareItems = [ShareableFileItem(fileURL: txtURL, title: "Sales Report TXT")]
                    self.showingShareSheet = true
                    self.isExporting = false
                }
            } else {
                DispatchQueue.main.async {
                    self.exportMessage = "Failed to generate TXT"
                    self.showingAlert = true
                    self.isExporting = false
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct SalesRowView: View {
    let record: SalesRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(record.product)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(record.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(String(format: "%.2f", record.total))")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("\(record.quantity) × $\(String(format: "%.2f", record.price))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

struct ExportButton: View {
    let title: String
    let icon: String
    let color: Color
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: icon)
                        .font(.title2)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
            )
            .foregroundColor(color)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: 1)
            )
        }
        .disabled(isLoading)
    }
}

#Preview {
    ContentView()
}
