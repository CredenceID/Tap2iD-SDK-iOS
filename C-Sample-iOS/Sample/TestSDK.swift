//
//  TestSDK.swift
//  C-Identity-Swift-Test-Project
//
//  Created by Deeprajj on 10/07/24.
//

import Foundation
import Tap2iDVerifierSDK

class TestSDK {

    var stateUpdate: String = ""
    var delegate: Tap2iDVerifySDKDelegate?

    func initSDK(apiKey: String, result: @escaping (String?,String?, String?) -> Void) {
        let sdkConfig = CoreSdkConfig(apiKey: apiKey)
        Tap2iDVerifySDK.shared.initSdk(config: sdkConfig) {[weak self] licenseResult in
            if let resultError = licenseResult.error {
                result(resultError as? String ?? resultError.localizedDescription, "", licenseResult.profileName)
            }else {
                var expiryDateStr: String?
                if let expiryDate = licenseResult.expiryDate {
                    expiryDateStr = self?.getLicenceExpiryDateAsString(date: Date.init(milliseconds: (expiryDate)))
                }
                let message = "isValid = \(licenseResult.isValid), \n ExpiryDate = \(expiryDateStr ?? "-")"
                result(licenseResult.error as? String ?? licenseResult.error?.localizedDescription, message, licenseResult.profileName)
            }
        }
    }

    func startQrEngagement(capturedQr: String, result: @escaping (Error?) -> Void) {
        let error = Tap2iDVerifySDK.shared.verifyMdoc(engagementConfig: .qrCode(capturedQr), delegate: self)
        if let error = error {
            result(error)
        }
    }

    /// Verifies a scanned PDF417 barcode (back of a driver's licence) using the dedicated
    /// PDF417 classifier API. `verifyPdf417` is async, so it is wrapped in a `Task`; the
    /// completion is delivered on the main actor.
    ///
    /// Unlike the mDoc engagement flow, this path does not emit `VerificationStage`
    /// callbacks — the typed `Pdf417VerificationResult` is returned directly.
    func startPdf417Verification(barcode: String,
                                 completion: @escaping (Result<Pdf417VerificationResult, Error>) -> Void) {
        Task {
            do {
                let request = Pdf417VerificationRequest(pdf417Value: barcode)
                let result = try await Tap2iDVerifySDK.shared.verifyPdf417(request: request)
                await MainActor.run { completion(.success(result)) }
            } catch {
                await MainActor.run { completion(.failure(error)) }
            }
        }
    }

    func startNFCEngagement(result: @escaping (Error?) -> Void) {
        let error = Tap2iDVerifySDK.shared.verifyMdoc(engagementConfig: .nfc, delegate: self)
        if let error = error {
            result(error)
        }
    }

    func startNFCReaderEngagement(readerDelegate: NfcExternalReaderDelegate, result: @escaping (Error?) -> Void) {
        let error = Tap2iDVerifySDK.shared.verifyMdoc(engagementConfig: .nfcExternalReader, delegate: self, readerDelegate: readerDelegate)
        if let error = error {
            result(error)
        }
    }

    func stopMonitoring() {
        Tap2iDVerifySDK.shared.stopMonitoring()
    }

    func getDeviceIdentifier() -> String? {
        Tap2iDVerifySDK.shared.getDeviceIdentifier()
    }

    private func getLicenceExpiryDateAsString(date: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = date else { return "" }
        return dateFormatter.string(from: date)
    }
}

extension TestSDK: Tap2iDVerifySDKDelegate {
    func onVerificationCompleted(verificationResult: VerificationResult?) {
        delegate?.onVerificationCompleted(verificationResult: verificationResult)
    }

    func onVerificationStageStarted(stage: VerificationStage) {
        delegate?.onVerificationStageStarted(stage: stage)
    }

    func onVerificationStageError(stage: VerificationStage?, error: CoreCredenceErrorStruct?) {
        delegate?.onVerificationStageError(stage: stage, error: error)
    }

    func onVerificationStageCompleted(stage: VerificationStage) {
        delegate?.onVerificationStageCompleted(stage: stage)
    }
}

extension Date {
    init(milliseconds: Int64) {
       self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
   }
}
