//
//  ViewController.swift
//  Sample
//
//  Created by Deeprajj on 16/07/24.
//

import UIKit
import Combine
import CoreBluetooth
import Tap2iDVerifierSDK

class ViewController: UIViewController {
    let testSDK = TestSDK()

    @IBOutlet weak var nfcButton: UIButton!
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
        let deviceIdentifier = testSDK.getDeviceIdentifier()
        messageLabel.text = "Tap2iD-Verify-SDK \n\nSample Version : \(UtilityManager.appVersion()) (\(UtilityManager.appBuildNumber())) \n\nDevice ID : \n\(deviceIdentifier ?? "-")"
        nfcButton.isEnabled = UIScreen.main.traitCollection.userInterfaceIdiom == .phone
        setupTextView()
    }

    func setupTextView() {
        textView.backgroundColor = .white // Force white background
        textView.isEditable = false

        // This prevents iOS from trying to "adapt" the colors for dark mode
        if #available(iOS 13.0, *) {
            textView.overrideUserInterfaceStyle = .light
        }
    }

    @IBAction func scanButtonClicked(_ sender: UIButton) {
        textView.text = ""
        imageView.image = UIImage.init(systemName: "rectangle.connected.to.line.below")
        let qrVC = storyboard?.instantiateViewController(withIdentifier: "QRScannerViewController") as! QRScannerViewController
        qrVC.modalPresentationStyle = .fullScreen
        qrVC.delegate = self
        present(qrVC, animated: true)
    }

    @IBAction func nfcButtonAction(_ sender: UIButton) {
        textView.text = ""
        imageView.image = UIImage.init(systemName: "rectangle.connected.to.line.below")
        contentView.isHidden = false
        engagementLabel.text = "NFC Engagement"
        testSDK.startNFCEngagement() { error in
            if error != nil {
                DispatchQueue.main.async {
                    self.textView.text =  "\(self.textView.text ?? "")\n There seems to be an issue with the initialization of the SDK. Please restart the application once more to complete the configuration"
                }
            }
        }
    }

    @IBAction func nfcReaderButtonAction(_ sender: UIButton) {
        textView.text = ""
        imageView.image = UIImage.init(systemName: "rectangle.connected.to.line.below")
        contentView.isHidden = false
        engagementLabel.text = "NFC Engagement"
        testSDK.startNFCReaderEngagement(readerDelegate: self) { error in
            if error != nil {
                DispatchQueue.main.async {
                    self.textView.text =  "\(self.textView.text ?? "")\n There seems to be an issue with the initialization of the SDK. Please restart the application once more to complete the configuration"
                }
            }
        }
    }

    @IBAction func doneAction(_ sender: UIButton) {
        contentView.isHidden = true
        textView.text = ""
        testSDK.stopMonitoring()
    }
}

extension ViewController: QRCodeScannerDelegate {
    func qrCodeScannerResult(qrCodeResult: String?, pdf417: String?, error: String?) {
        contentView.isHidden = false
        engagementLabel.text = "QRCode Engagement"
        if let pdf417 {
            engagementLabel.text = "PDF417 Verification"
            textView.text = "Verifying PDF417 barcode…"
            testSDK.startPdf417Verification(barcode: pdf417) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let pdf417Result):
                    self.render(html: pdf417Result.toHTMLString())
                case .failure(let error):
                    self.render(html: Self.pdf417FailureHTML(error))
                }
            }
            return
        }
        DispatchQueue.global().async {
            self.testSDK.startQrEngagement(capturedQr: qrCodeResult ?? "Test") { error in
                if error != nil {
                    DispatchQueue.main.async {
                        self.textView.text =  "\(self.textView.text ?? "")\n There seems to be an issue with the initialization of the SDK. Please restart the application once more to complete the configuration"
                    }
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
    func onVerificationCompleted(verificationResult: VerificationResult?) {
        guard let result = verificationResult else { return }
        render(html: result.toHTMLString())
    }

    /// Renders an HTML report into the result text view. Parsing happens off the main
    /// thread; the attributed string is applied back on main. Shared by the mDoc and
    /// PDF417 result paths.
    func render(html: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let attributed = Self.attributedString(fromHTML: html)
            DispatchQueue.main.async { [weak self] in
                self?.textView.attributedText = attributed
            }
        }
    }

    private static func pdf417FailureHTML(_ error: Error) -> String {
        let message = error.localizedDescription
        let suggestion = (error as? LocalizedError)?.recoverySuggestion
        var body = "<h2 style='color:#D32F2F;margin:0 0 12px;'>PDF417 Verification</h2>"
        body += "<p style='font-size:15px;margin:0 0 12px;'>\(message)</p>"
        if let suggestion = suggestion {
            body += "<p style='font-size:13px;color:#757575;margin:0;'>\(suggestion)</p>"
        }
        return "<html><head><meta name='viewport' content='width=device-width, initial-scale=1'></head>"
            + "<body style=\"font-family:-apple-system,sans-serif;padding:24px;color:#212121;\">"
            + body + "</body></html>"
    }

    private static func attributedString(fromHTML html: String) -> NSAttributedString? {
        let data = Data(html.utf8)
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        return try? NSAttributedString(data: data, options: options, documentAttributes: nil)
    }

    func onVerificationStageStarted(stage: VerificationStage) {
        DispatchQueue.main.async {
            self.textView.text =  "\(self.textView.text ?? "")\n \(self.getStageString(stage: stage, started: true))"
        }
    }

    func onVerificationStageError(stage: VerificationStage?, error: CoreCredenceErrorStruct?) {
        DispatchQueue.main.async {
            self.textView.text = "\(self.textView.text ?? "")\n\n Error = \(error?.errorMessage ?? "Unknown error")"
        }
    }

    func onVerificationStageCompleted(stage: VerificationStage) {
        DispatchQueue.main.async {
            self.textView.text = "\(self.textView.text ?? "")\n \(self.getStageString(stage: stage, started: false))"
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
        case .VALIDATE_MDOC_RESPONSE:
            return "\((started ? "Started" : "Completed")) : VALIDATE_MDOC_RESPONSE"
        case .PDF417:
            return "\((started ? "Started" : "Completed")) : PDF417"
        @unknown default:
            return "\((started ? "Started" : "Completed")) : default"
        }
    }

    private func preparePortrait(portrait: String?) -> UIImage? {
        if let photoData = portrait?.data, let image = UIImage(data: photoData) {
            return image
        }
        return nil
    }
}

extension ViewController: NfcExternalReaderDelegate {
    func didDetectReaders() {
        DispatchQueue.main.async {
            self.textView.text = "\(self.textView.text ?? "")\n\n Reader Detected"
        }
    }

    func didDisconnectFromReader() {
        DispatchQueue.main.async {
            self.textView.text = "\(self.textView.text ?? "")\n\n Disconnect From Reader"
        }
    }

    func didDetectSmartCard() {
        DispatchQueue.main.async {
            self.textView.text = "\(self.textView.text ?? "")\n\n Smart Card Detected"
        }
    }

    func didDisconnectFromSmartCard() {
        DispatchQueue.main.async {
            self.textView.text = "\(self.textView.text ?? "")\n\n Disconnect From Smart Card "
        }
    }
}

extension String {
    var data: Data? {
       let data = NSMutableData(capacity: self.count)
       let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
       let range = NSRange(location: 0, length: count)
       regex?.enumerateMatches(in: self, options: [], range: range) { match, _, _ in
           let byteString = (self as NSString).substring(with: match!.range)
           var num = UInt8(byteString, radix: 16)
           data?.append(&num, length: 1)
       }
       return data as? Data
   }
}
