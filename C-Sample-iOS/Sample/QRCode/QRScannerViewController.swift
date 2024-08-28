//
//  QRScannerViewController.swift
//  C-Identity-Swift-Test-Project
//
//  Created by Deeprajj on 25/06/24.
//

import UIKit

protocol QRCodeScannerDelegate {
    func qrCodeScannerResult(qrCodeResult: String?, error: String?)
}

class QRScannerViewController: UIViewController {
    // MARK: - IBOutlets & Variables
    @IBOutlet weak var scannerView: QRScannerView!

    var delegate: QRCodeScannerDelegate?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scannerView.scannerDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !scannerView.isRunning {
            scannerView.startScanning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !scannerView.isRunning {
            scannerView.stopScanning()
        }
    }

    @IBAction func cancelButtonAction(sender: Any) {
        dismiss(animated: true)
    }
}

extension QRScannerViewController: QAScannerViewDelegate {
    func qrScanningDidFail() {
        self.closeView(result: nil, error: "Scanning Failed. Please try again")
    }

    func qrScanningSucceededWithCode(_ code: String?) {
        self.closeView(result: code, error: nil)
    }

    func qrScanningDidStop() {
//        self.closeView(result: nil, error: nil)
    }

    func closeView(result: String?, error: String?) {
        dismiss(animated: true)
        if let result = result {
            delegate?.qrCodeScannerResult(qrCodeResult: result, error: nil)
        }else{
            dismiss(animated: true) { [weak self] in
                self?.delegate?.qrCodeScannerResult(qrCodeResult: nil, error: error)
            }
        }
    }
}
