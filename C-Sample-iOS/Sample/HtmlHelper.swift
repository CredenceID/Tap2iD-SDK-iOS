//
//  HtmlHelper.swift
//  Sample
//
//  Created by Deeprajj on 15/01/26.
//

import Foundation
import Tap2iDVerifierSDK
import UIKit

extension VerificationResult {

    public func toHTMLString() -> String {
        // Define colors and styles to match the professional Android implementation
        let css = """
        <style>
            :root {
                --primary: #007AFF;
                --success: #2E7D32;
                --error: #D32F2F;
                --warning: #F57C00;
                --text-main: #212121;
                --text-secondary: #757575;
                --bg-main: #FFFFFF;
                --divider: #E0E0E0;
            }
            html, body { 
                background-color: var(--bg-main) !important; 
                margin: 0; 
                padding: 0; 
                -webkit-text-size-adjust: none;
            }
            body { s
                font-family: -apple-system, sans-serif; 
                padding: 24px; 
                color: var(--text-main); 
                line-height: 1.5;
            }
            .report-container { max-width: 600px; margin: 0 auto; }
            
            /* Header */
            .main-header { text-align: center; margin-bottom: 32px; padding-bottom: 16px; border-bottom: 2px solid var(--divider); }
            .report-title { margin: 0; font-size: 24px; font-weight: 700; color: var(--text-main); }
            .report-status { margin-top: 8px; font-size: 16px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
            .status-success { color: var(--success); }
            .status-warning { color: var(--warning); }
            .status-failure { color: var(--error); }
            
            /* Sections */
            .doc-section { margin-bottom: 40px; }
            .doc-type { font-size: 20px; font-weight: 700; color: var(--primary); margin-bottom: 24px; }
            .group-title { font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-secondary); letter-spacing: 1px; margin-bottom: 8px; border-bottom: 1px solid var(--divider); padding-bottom: 4px; margin-top: 24px; }
            
            /* Portrait */
            .portrait-wrapper { text-align: center; margin-bottom: 32px; }
            .portrait-img { height: 180px; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
            
            /* Data Tables */
            .data-table { width: 100%; border-collapse: collapse; table-layout: fixed; }
            .data-row-cell { padding: 10px 0; border-bottom: 1px solid #F0F0F0; vertical-align: top; }
            .key { color: var(--text-secondary); font-size: 14px; text-align: left; width: 40%; }
            .value { font-weight: 500; text-align: right; color: var(--text-main); font-size: 14px; word-wrap: break-word; }
            
            /* Status Indicators */
            .check-item { color: var(--text-main); font-size: 14px; }
            .check-success { color: var(--success); }
            .check-error { color: var(--error); }
            
            /* Error Box */
            .error-container { background-color: #FFEBEE; padding: 16px; border-radius: 8px; margin-top: 24px; border: 1px solid #FFCDD2; }
            .error-title { color: var(--error); font-weight: bold; font-size: 14px; margin-bottom: 8px; display: block; }
            .error-msg { font-size: 13px; color: #B71C1C; display: block; margin-bottom: 4px; }
        </style>
        """

        var html = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1'>\(css)</head><body>"
        html += "<div class='report-container'>"

        // 1. Overall Header
        let (statusClass, statusText) = getStatusDetails()
        html += "<div class='main-header'>"
        html += "<h1 class='report-title'>Verification Report</h1>"
        html += "<div class='report-status \(statusClass)'>\(statusText)</div>"
        html += "</div>"

        if documents.isEmpty {
            html += "<p style='text-align:center; color:#757575;'>No documents processed.</p>"
        }

        // 2. Document Loop
        for doc in documents {
            html += "<div class='doc-section'>"

            let displayDocType = doc.docType.uppercased().replacingOccurrences(of: "ORG.ISO.18013.5.1.", with: "")
            html += "<h2 class='doc-type'>\(displayDocType)</h2>"

            // Portrait
            if let base64Portrait = findPortraitBase64(in: doc) {
                html += "<div class='portrait-wrapper'><img src='\(base64Portrait)' class='portrait-img'/></div>"
            }

            let auth = doc.authentication

            // --- Security Checks ---
            html += "<div class='group-title'>SECURITY CHECKS</div>"
            html += renderCheckRow(label: "Issuer Signature", isValid: auth.security.isIssuerSignedValid)
            html += renderCheckRow(label: "Device Signature", isValid: auth.security.isDeviceSignedValid)
            html += renderCheckRow(label: "Data Integrity", isValid: auth.security.areDigestsValid)

            let isTrusted = auth.trust.chainStatus == .verified
            html += renderCheckRow(label: "Root of Trust (\(auth.trust.chainStatus.rawValue.uppercased()))", isValid: isTrusted)

            // --- Validity ---
            html += "<div class='group-title'>VALIDITY PERIOD</div>"
            html += renderDataRow(key: "Valid From", value: auth.msoValidity.validFromTimestamp.toHtmlDate())

            let now = Int64(Date().timeIntervalSince1970 * 1000)
            let isExpired = (auth.msoValidity.validUntilTimestamp ?? Int64.max) < now
            let expiryStr = auth.msoValidity.validUntilTimestamp.toHtmlDate()
            let expiryHtml = isExpired ? "<span style='color:var(--error); font-weight:bold;'>\(expiryStr) (Expired)</span>" : expiryStr

            html += renderDataRow(key: "Valid Until", value: expiryHtml)
            html += renderDataRow(key: "MSO Status", value: auth.msoValidity.status.rawValue.uppercased())

            // --- Identity Data ---
            html += "<div class='group-title'>IDENTITY DATA</div>"
            let allAttributes = doc.nameSpaces.flatMap { $0.attributes }

            if allAttributes.isEmpty {
                html += "<p style='font-style:italic; color:#757575;'>No data attributes found.</p>"
            } else {
                let sortedKeys = allAttributes.map { $0.key }.sorted()
                for key in sortedKeys {
                    if key == "portrait" { continue }
                    if let val = allAttributes.first(where: { $0.key == key })?.value {
                        let prettyKey = key.replacingOccurrences(of: "_", with: " ").capitalized
                        let displayVal = (val is Data) ? "[Binary Data]" : "\(val)"
                        html += renderDataRow(key: prettyKey, value: displayVal)
                    }
                }
            }

            // --- Errors ---
            if !auth.errors.isEmpty {
                html += "<div class='error-container'><span class='error-title'>VALIDATION ERRORS</span>"
                for error in auth.errors { html += "<span class='error-msg'>• \(error)</span>" }
                html += "</div>"
            }

            html += "</div>"
        }

        html += "</div></body></html>"
        return html
    }

    // MARK: - Private Helpers

    private func getStatusDetails() -> (String, String) {
        switch status {
        case .success: return ("status-success", "PASSED")
        case .partialSuccess: return ("status-warning", "PARTIAL SUCCESS")
        case .failure: return ("status-failure", "FAILED")
        @unknown default:
            return ("status-failure", "FAILED")
        }
    }

    private func renderDataRow(key: String, value: String) -> String {
        return """
        <table class="data-table">
            <tr>
                <td class="data-row-cell key">\(key)</td>
                <td class="data-row-cell value">\(value)</td>
            </tr>
        </table>
        """
    }

    private func renderCheckRow(label: String, isValid: Bool) -> String {
        let colorClass = isValid ? "check-success" : "check-error"
        let icon = isValid ? "&#10003;" : "&#10007;"
        return """
        <table class="data-table">
            <tr>
                <td class="data-row-cell \(colorClass)" style="width: 25px; font-weight: bold;">\(icon)</td>
                <td class="data-row-cell \(colorClass)" style="text-align: left; font-size: 14px;">\(label)</td>
            </tr>
        </table>
        """
    }

    private func findPortraitBase64(in doc: VerifiedDocument) -> String? {
        for ns in doc.nameSpaces {
            if let portrait = ns.attributes["portrait"] {
                if let img = portrait as? UIImage { return img.toBase64String() }
                if let data = portrait as? Data, let img = UIImage(data: data) { return img.toBase64String() }
            }
        }
        return nil
    }
}

// MARK: - Utility Extensions

extension UIImage {
    func toBase64String() -> String? {
        let targetHeight: CGFloat = 300
        let scale = targetHeight / self.size.height
        let targetWidth = self.size.width * scale
        let size = CGSize(width: targetWidth, height: targetHeight)

        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let data = scaledImage?.jpegData(compressionQuality: 0.7) else { return nil }
        return "data:image/jpeg;base64,\(data.base64EncodedString())"
    }
}

extension Int64? {
    func toHtmlDate() -> String {
        guard let miliseconds = self else { return "N/A" }
        let date = Date(timeIntervalSince1970: TimeInterval(miliseconds) / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}
