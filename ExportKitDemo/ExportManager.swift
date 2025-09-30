//
//  ExportManager.swift
//  ExportKitDemo
//
//  Created by kent.sun on 2025/9/30.
//

import Foundation
import UIKit
import PDFKit

class ExportManager: ObservableObject {
    
    static let shared = ExportManager()
    
    init() {}
    
    // MARK: - PDF Export
    func generatePDF(from salesRecords: [SalesRecord]) -> URL? {
        let pageWidth: CGFloat = 612.0
        let pageHeight: CGFloat = 792.0
        let margin: CGFloat = 50.0
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "SalesReport_\(formatDateForFilename(Date())).pdf"
        let pdfURL = documentsDirectory.appendingPathComponent(fileName)
        
        UIGraphicsBeginPDFContextToFile(pdfURL.path, CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), nil)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        UIGraphicsBeginPDFPage()
        
        var yPosition: CGFloat = margin
        
        // Title
        let titleText = "Sales Report"
        let titleFont = UIFont.boldSystemFont(ofSize: 24)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]
        let titleSize = titleText.size(withAttributes: titleAttributes)
        let titleRect = CGRect(x: (pageWidth - titleSize.width) / 2, y: yPosition, width: titleSize.width, height: titleSize.height)
        titleText.draw(in: titleRect, withAttributes: titleAttributes)
        yPosition += titleSize.height + 20
        
        // Date
        let dateText = "Generated on: \(formatDate(Date()))"
        let dateFont = UIFont.systemFont(ofSize: 12)
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: dateFont,
            .foregroundColor: UIColor.gray
        ]
        let dateSize = dateText.size(withAttributes: dateAttributes)
        let dateRect = CGRect(x: (pageWidth - dateSize.width) / 2, y: yPosition, width: dateSize.width, height: dateSize.height)
        dateText.draw(in: dateRect, withAttributes: dateAttributes)
        yPosition += dateSize.height + 30
        
        // Summary
        let totalSales = salesRecords.reduce(0) { $0 + $1.total }
        let summaryText = "Total Sales: $\(String(format: "%.2f", totalSales)) | Total Records: \(salesRecords.count)"
        let summaryFont = UIFont.boldSystemFont(ofSize: 14)
        let summaryAttributes: [NSAttributedString.Key: Any] = [
            .font: summaryFont,
            .foregroundColor: UIColor.black
        ]
        let summarySize = summaryText.size(withAttributes: summaryAttributes)
        let summaryRect = CGRect(x: margin, y: yPosition, width: pageWidth - 2 * margin, height: summarySize.height)
        summaryText.draw(in: summaryRect, withAttributes: summaryAttributes)
        yPosition += summarySize.height + 20
        
        // Table Header
        let headerFont = UIFont.boldSystemFont(ofSize: 10)
        let cellFont = UIFont.systemFont(ofSize: 9)
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.white
        ]
        let cellAttributes: [NSAttributedString.Key: Any] = [
            .font: cellFont,
            .foregroundColor: UIColor.black
        ]
        
        let rowHeight: CGFloat = 25
        let tableWidth = pageWidth - 2 * margin
        let columnWidths: [CGFloat] = [80, 100, 60, 60, 80, 80, 80]
        
        // Header background
        context.setFillColor(UIColor.systemBlue.cgColor)
        context.fill(CGRect(x: margin, y: yPosition, width: tableWidth, height: rowHeight))
        
        // Header text
        let headers = ["Date", "Product", "Qty", "Price", "Total", "Customer", "Region"]
        var xPosition: CGFloat = margin
        for (index, header) in headers.enumerated() {
            let headerRect = CGRect(x: xPosition + 5, y: yPosition + 5, width: columnWidths[index] - 10, height: rowHeight - 10)
            header.draw(in: headerRect, withAttributes: headerAttributes)
            xPosition += columnWidths[index]
        }
        yPosition += rowHeight
        
        // Table rows
        for (index, record) in salesRecords.enumerated() {
            if yPosition > pageHeight - margin - rowHeight {
                UIGraphicsBeginPDFPage()
                yPosition = margin
            }
            
            // Alternating row colors
            if index % 2 == 0 {
                context.setFillColor(UIColor.systemGray6.cgColor)
                context.fill(CGRect(x: margin, y: yPosition, width: tableWidth, height: rowHeight))
            }
            
            // Row data
            let rowData = [
                record.formattedDate,
                record.product,
                "\(record.quantity)",
                "$\(String(format: "%.2f", record.price))",
                "$\(String(format: "%.2f", record.total))",
                record.customer,
                record.region
            ]
            
            xPosition = margin
            for (colIndex, data) in rowData.enumerated() {
                let cellRect = CGRect(x: xPosition + 5, y: yPosition + 5, width: columnWidths[colIndex] - 10, height: rowHeight - 10)
                data.draw(in: cellRect, withAttributes: cellAttributes)
                xPosition += columnWidths[colIndex]
            }
            yPosition += rowHeight
        }
        
        UIGraphicsEndPDFContext()
        
        return pdfURL
    }
    
    // MARK: - CSV Export
    func generateCSV(from salesRecords: [SalesRecord]) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "SalesData_\(formatDateForFilename(Date())).csv"
        let csvURL = documentsDirectory.appendingPathComponent(fileName)
        
        var csvContent = "Date,Product,Quantity,Price,Total,Customer,Region\n"
        
        for record in salesRecords {
            let line = "\(record.formattedDate),\(record.product),\(record.quantity),\(String(format: "%.2f", record.price)),\(String(format: "%.2f", record.total)),\(record.customer),\(record.region)\n"
            csvContent += line
        }
        
        do {
            try csvContent.write(to: csvURL, atomically: true, encoding: .utf8)
            return csvURL
        } catch {
            print("Error writing CSV: \(error)")
            return nil
        }
    }
    
    // MARK: - TXT Export
    func generateTXT(from salesRecords: [SalesRecord]) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "SalesReport_\(formatDateForFilename(Date())).txt"
        let txtURL = documentsDirectory.appendingPathComponent(fileName)
        
        var txtContent = """
        SALES REPORT
        Generated on: \(formatDate(Date()))
        
        SUMMARY
        Total Sales: $\(String(format: "%.2f", salesRecords.reduce(0) { $0 + $1.total }))
        Total Records: \(salesRecords.count)
        
        DETAILED RECORDS
        ================
        
        """
        
        for (index, record) in salesRecords.enumerated() {
            txtContent += """
            Record #\(index + 1)
            Date: \(record.formattedDate)
            Product: \(record.product)
            Quantity: \(record.quantity)
            Price: $\(String(format: "%.2f", record.price))
            Total: $\(String(format: "%.2f", record.total))
            Customer: \(record.customer)
            Region: \(record.region)
            
            """
        }
        
        do {
            try txtContent.write(to: txtURL, atomically: true, encoding: .utf8)
            return txtURL
        } catch {
            print("Error writing TXT: \(error)")
            return nil
        }
    }
    
    // MARK: - Helper Methods
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDateForFilename(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: date)
    }
}
