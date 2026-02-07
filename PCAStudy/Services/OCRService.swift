import Foundation
import Vision
import PDFKit
import UIKit

struct OCRResult {
    let pageNumber: Int
    let text: String
}

final class OCRService {
    func recognizeText(from pdfDocument: PDFDocument, progress: @escaping (Int, Int) -> Void) async throws -> [OCRResult] {
        let pageCount = pdfDocument.pageCount
        var results: [OCRResult] = []
        results.reserveCapacity(pageCount)

        for pageIndex in 0..<pageCount {
            try Task.checkCancellation()
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            let image = try renderPage(page)
            let text = try await recognizeText(in: image)
            results.append(OCRResult(pageNumber: pageIndex + 1, text: text))
            progress(pageIndex + 1, pageCount)
        }

        return results
    }

    private func renderPage(_ page: PDFPage) throws -> UIImage {
        let pageRect = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(pageRect)
            context.cgContext.translateBy(x: 0, y: pageRect.size.height)
            context.cgContext.scaleBy(x: 1.0, y: -1.0)
            page.draw(with: .mediaBox, to: context.cgContext)
        }
    }

    private func recognizeText(in image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else { return "" }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                continuation.resume(returning: text)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["es-ES", "en-US"]

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
