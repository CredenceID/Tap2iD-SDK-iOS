//
//  QRScannerView.swift
//  C-Identity-Swift-Test-Project
//
//  Created by Deeprajj on 25/06/24.
//

import Foundation
import UIKit
import AVFoundation

protocol QAScannerViewDelegate: AnyObject {
    func qrScanningDidFail()
    func qrScanningSucceededWithCode(_ code: String?)
    func qrScanningDidStop()
}

class QRScannerView: UIView {
    /// capture session which allows us to start and stop scanning.
    var captureSession: AVCaptureSession?

    weak var scannerDelegate: QAScannerViewDelegate?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }

    //MARK: overriding the layerClass to return `AVCaptureVideoPreviewLayer`.
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    override var layer: AVCaptureVideoPreviewLayer {
        return super.layer as! AVCaptureVideoPreviewLayer
    }
}

extension QRScannerView {
     var isRunning: Bool {
        return captureSession?.isRunning ?? false
    }

    func startScanning() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }

    func stopScanning() {
        captureSession?.stopRunning()
        scannerDelegate?.qrScanningDidStop()
    }

    private func initialSetup() {
        clipsToBounds = true
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }

        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch let error {
            print("AVCaptureDeviceInput Error = ", error)
            return
        }

        if captureSession?.canAddInput(videoInput) ?? false {
            captureSession?.addInput(videoInput)
        } else {
            scanningDidFail()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession?.canAddOutput(metadataOutput) ?? false {
            captureSession?.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            scanningDidFail()
            return
        }
        self.layer.session = captureSession
        self.layer.videoGravity = .resizeAspectFill
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }

    func scanningDidFail() {
        scannerDelegate?.qrScanningDidFail()
        captureSession = nil
    }

    func found(code: String) {
        scannerDelegate?.qrScanningSucceededWithCode(code)
    }
}

extension QRScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        stopScanning()
        var qrCodeStringValue = ""
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue  {
            qrCodeStringValue = stringValue
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        found(code: qrCodeStringValue)
    }
}
