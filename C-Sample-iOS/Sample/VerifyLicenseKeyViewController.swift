//
//  VerifyLicenseKeyViewController.swift
//  Sample
//
//  Created by Deeprajj on 13/08/24.
//

import UIKit
import CIdentitySwift

class VerifyLicenseKeyViewController: UIViewController {

    @IBOutlet weak var buttonVerify: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var validityLabel: UILabel!

    let testSDK = TestSDK()

    override func viewDidLoad() {
        super.viewDidLoad()

        keyTextField.text = "CSQie5dcdBIcPv4aKVuMtJZLhtOIuMcqh9"
        keyTextField.clearButtonMode = .always

        let deviceIdentifier = WebServiceSecurity().decryptCipher(valueToDecrypt: KeychainHelper.deviceIdentifier())
        messageLabel.text = "Tap2iD-Verify-SDK \n\nSample Version : \(UtilityManager.appVersion()) (\(UtilityManager.appBuildNumber())) \n\nDevice ID : \n\(deviceIdentifier ?? "-")"
    }

    @IBAction func verifyAction(_ sender: UIButton) {
        view.endEditing(true)
        buttonVerify.isEnabled = false
        guard let key = keyTextField.text,
        key.count > 31
        else {
            buttonVerify.isEnabled = true
            errorLabel.text = "Please provide a valid license key generated on the VwC portal and tagged with your package name"
            return
        }

        testSDK.initSDK(apiKey: keyTextField.text ?? "") {[weak self] (error, message) in
            guard let self = self else { return }
            self.validityLabel.text = "\(message ?? "")"
            self.errorLabel.text = error

            if error != nil {
                self.buttonVerify.isEnabled = true
                return
            }
            self.buttonNext.isEnabled = true
            self.keyTextField.isEnabled = false
            self.keyTextField.textColor = .green
        }
    }

    @IBAction func nextAction(_ sender: UIButton) {
        navigationController?.pushViewController(storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController, animated: true)
    }
}

extension VerifyLicenseKeyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLabel.text = ""
    }
}
