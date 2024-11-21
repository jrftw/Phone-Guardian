//
//  ReportsView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/19/24.
//

import SwiftUI
import PDFKit

struct ReportsView: View {
    @State private var showShareSheet = false
    @State private var pdfURL: URL?

    var body: some View {
        VStack {
            Button("Export Report") {
                generatePDFReport()
            }
            .padding()

            if let pdfURL = pdfURL {
                Button("Share Report") {
                    showShareSheet = true
                }
                .padding()
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(activityItems: [pdfURL])
                }
            }
        }
        .navigationTitle("Reports")
    }

    func generatePDFReport() {
        // Create PDF content
        let pdfContent = createPDFContent()

        // Define the page bounds
        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792) // Letter size
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)

        let data = renderer.pdfData { context in
            context.beginPage()
            pdfContent.draw(at: CGPoint(x: 20, y: 20))
        }

        // Save the PDF
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pdfFileURL = documentDirectory.appendingPathComponent("PhoneGuardianReport.pdf")
            do {
                try data.write(to: pdfFileURL)
                self.pdfURL = pdfFileURL
                print("PDF saved to \(pdfFileURL)")
            } catch {
                print("Error saving PDF: \(error)")
            }
        }
    }

    func createPDFContent() -> NSAttributedString {
        let content = """
        Phone Guardian Report
        =====================

        Date: \(Date().formatted(date: .numeric, time: .shortened))

        Summary:
        - Battery Health: Good
        - CPU Usage: Normal
        - RAM Usage: 70%
        - Storage: 50% Free
        - Network Status: Stable

        Thank you for using Phone Guardian!
        """

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .left
                style.lineSpacing = 6
                return style
            }()
        ]

        return NSAttributedString(string: content, attributes: attributes)
    }
}

// MARK: - ShareSheet for sharing the PDF
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
