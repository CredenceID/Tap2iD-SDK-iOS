//
//  ViewController.swift
//  Sample
//
//  Created by Deeprajj on 16/07/24.
//

import UIKit
import Combine
import CoreBluetooth
import CIdentitySwift

class ViewController: UIViewController {
    let testSDK = TestSDK()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var engagementLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    private var bleObserver: BLEObserver!
    private var cancellables = Set<AnyCancellable>()
    var bleState: CBManagerState = .unknown
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testSDK.delegate = self
        bleObserver = BLEObserver()
        bleObserver.startCentralManager()
        let deviceIdentifier = WebServiceSecurity().decryptCipher(valueToDecrypt: KeychainHelper.deviceIdentifier())

        messageLabel.text = "Tap2iD-Verify-SDK \n\nSample Version : \(UtilityManager.appVersion()) (\(UtilityManager.appBuildNumber())) \n\nDevice ID : \n\(deviceIdentifier ?? "-")"
    }

    @IBAction func scanButtonClicked(_ sender: UIButton) {
        textView.text = ""
        imageView.image = UIImage.init(systemName: "rectangle.connected.to.line.below")
        let qrVC = storyboard?.instantiateViewController(withIdentifier: "QRScannerViewController") as! QRScannerViewController
        qrVC.modalPresentationStyle = .fullScreen
        qrVC.delegate = self
        present(qrVC, animated: true)
    }

    @IBAction func doneAction(_ sender: UIButton) {
        contentView.isHidden = true
        textView.text = ""
    }
}

extension ViewController: QRCodeScannerDelegate {
    func qrCodeScannerResult(qrCodeResult: String?, error: String?) {
        contentView.isHidden = false
        engagementLabel.text = "QRCode Engagement"
        testSDK.startQrEngagement(capturedQr: qrCodeResult ?? "Test") { error in
            if error != nil {
                DispatchQueue.main.async {
                    self.textView.text =  "\(self.textView.text ?? "")\n There seems to be an issue with the initialization of the SDK. Please restart the application once more to complete the configuration"
                }
            }
        }
    }
}

extension ViewController {
    private func setupPublisher() {
        bleObserver?.$bleState
            .sink { [weak self] state in
                self?.bleState = state
            }
            .store(in: &cancellables)

    }
}

extension ViewController: Tap2iDVerifySDKDelegate {

    func onVerificationStageStarted(stage: VerificationStage) {
        DispatchQueue.main.async {
            self.textView.text =  "\(self.textView.text ?? "")\n \(self.getStageString(stage: stage, started: true))"
        }
    }

    func onVerificationStageError(stage: VerificationStage?, error: CoreCredenceErrorStruct?) {
        DispatchQueue.main.async {
            self.textView.text = "\(self.textView.text ?? "")\n\n Error = \(error?.messageForVerifyPortal ?? "Unknown error")"
        }
    }

    func onVerificationStageCompleted(stage: VerificationStage) {
        DispatchQueue.main.async {
            self.textView.text = "\(self.textView.text ?? "")\n \(self.getStageString(stage: stage, started: false))"
        }
    }

    func onVerificationCompleted(result: MdlAttributes, validationResult: [CoreCredenceErrorStruct]) {
        var errorString = ""
        validationResult.forEach { error in
            if errorString == "" {
                errorString = "\n\n Validation error = "
            }
            errorString += "\n\(error.messageForVerifyPortal)"
        }
        DispatchQueue.main.async { [weak self] in
            self?.textView.text = "\(self?.textView.text ?? "")\n\n Verification Completed"
            self?.textView.text = "\(self?.textView.text ?? "")\(self?.getDisplayString(models: ResultHelperTest.prepareDisplayModel(model: result)) ?? "") \(errorString)"
            self?.imageView.image = self?.preparePortrait(portrait: result.portrait)
        }
    }

    func getStageString(stage: VerificationStage, started: Bool) -> String {
        switch stage {
        case .NFC_ENGAGEMENT:
            return "\((started ? "Started" : "Completed")) : NFC_ENGAGEMENT"
        case .QR_ENGAGEMENT:
            return "\((started ? "Started" : "Completed")) : QR_ENGAGEMENT"
        case .CONNECTION:
            return "\((started ? "Started" : "Completed")) : CONNECTION"
        case .SEND_MDOC_REQUEST:
            return "\((started ? "Started" : "Completed")) : SEND_MDOC_REQUEST"
        case .READ_MDOC_RESPONSE:
            return "\((started ? "Started" : "Completed")) : READ_MDOC_RESPONSE"
        case .PARSE_MDOC_RESPONSE:
            return "\((started ? "Started" : "Completed")) : PARSE_MDOC_RESPONSE"
        @unknown default:
            return "\((started ? "Started" : "Completed")) : default"
        }
    }

    private func getDisplayString(models: ([IdCustomResultModelTest],[IdCustomResultModelTest])) -> String {
        var returnString = "\n"

        let model1 = models.0
        let model2 = models.1

        for model in model1 {
            returnString += "\n" + model.title + "  =  " + (model.value ?? "-")
        }

        for model in model2 {
            returnString += "\n" + model.title + "  =  " + (model.value ?? "-")
        }

        return returnString
    }

    private func preparePortrait(portrait: String?) -> UIImage? {
        if let photoData = portrait?.data, let image = UIImage(data: photoData) {
            return image
        }
        return nil
    }
}



class UtilityManager {

    static func appVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return ""
    }

    static func osVersion() -> String {
        return UIDevice.current.systemVersion
    }

    static func appBuildNumber() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return appVersion
        }
        return ""
    }

    static func generateHashValueFor(input: String) -> String {
        return String(input.hashValue)
    }

    static func getVersionWithBuildNumber() -> String {
        return "Version \(appVersion())"
    }
}
