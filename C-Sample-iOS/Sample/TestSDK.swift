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

    func startPdfEngagement(pdf417: String, result: @escaping (Error?) -> Void) {
        let error = Tap2iDVerifySDK.shared.verifyMdoc(engagementConfig: .pdf417(pdf417), delegate: self)
        if let error = error {
            result(error)
        }
    }

    func verifyPDF417FromDL(pdf417: String,
                            completion: @escaping (PDF417VerificationResult) -> Void) -> Error? {
        return Tap2iDVerifySDK.shared.verifyPDF417FromDL(barcodeString: pdf417, completion: completion)
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
