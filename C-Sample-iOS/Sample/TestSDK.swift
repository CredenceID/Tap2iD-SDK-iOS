//
//  TestSDK.swift
//  C-Identity-Swift-Test-Project
//
//  Created by Deeprajj on 10/07/24.
//

import Foundation
import CIdentitySwift

class TestSDK {

    var stateUpdate: String = ""
    var delegate: Tap2iDVerifySDKDelegate?

    func initSDK(apiKey: String, result: @escaping (String?,String?) -> Void) {
        let sdkConfig = CoreSdkConfig(apiKey: apiKey)
        Tap2iDVerifySDK.shared.initSdk(config: sdkConfig) { (error, message) in
            result(error, message)
        }
    }

    func startQrEngagement(capturedQr: String, result: @escaping (Error?) -> Void) {
        let error = Tap2iDVerifySDK.shared.verifyMdoc(engagementConfig: .qrCode(capturedQr), delegate: self)
        if let error = error {
            result(error)
        }
    }
}

extension TestSDK: Tap2iDVerifySDKDelegate {
    func onVerificationStageStarted(stage: VerificationStage) {
        delegate?.onVerificationStageStarted(stage: stage)
    }
    
    func onVerificationStageError(stage: VerificationStage?, error: CoreCredenceErrorStruct?) {
        delegate?.onVerificationStageError(stage: stage, error: error)
    }
    
    func onVerificationStageCompleted(stage: VerificationStage) {
        delegate?.onVerificationStageCompleted(stage: stage)
    }
    
    func onVerificationCompleted(result: MdlAttributes, validationResult: [CoreCredenceErrorStruct]) {
        delegate?.onVerificationCompleted(result: result, validationResult: validationResult)
    }
}

extension MdlAttributes {
    var birthDateFormatted: String? {
        guard let result = convertDate(input: birthDate) else {
            return nil
        }
        return result
    }

    private func convertDate(input: String?) -> String? {
        guard let inputDate = input else { return nil }
        var date: Date?
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        date = dateFormatter.date(from: inputDate)
        if date == nil {
            date = ISO8601DateFormatter().date(from: inputDate)
        }
        guard let date = date else { return nil }
        dateFormatter.dateFormat = "YYYY/MM/dd"
        let result = dateFormatter.string(from: date)
        return result
    }

    var sexValue: String? {
        guard let sex = sex else {
            return nil
        }
        switch sex {
        case "0": return "Not known"
        case "1": return "Male"
        case "2": return "Female"
        case "9": return "NA"
        default: return nil
        }
    }

    var issueDateFormatted: String? {
        guard let result = convertDate(input: issueDate) else {
            return nil
        }
        return result
    }

    var expiryDateFormatted: String? {
        guard let result = convertDate(input: expiryDate) else {
            return nil
        }
        return result
    }
}

struct IdCustomResultModelTest {
    let title: String
    let value: String?
}

class ResultHelperTest {

    static func prepareDisplayModel(model: MdlAttributes?) -> ([IdCustomResultModelTest],[IdCustomResultModelTest]) {
        var allIdGeetResults: [IdCustomResultModelTest] = []
        var drivingPrivilegeResult: [IdCustomResultModelTest] = []

        if model?.firstName != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "First Name", value: model?.firstName))
        }
        if model?.lastName != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Last Name", value: model?.lastName))
        }
        if model?.birthDate != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Birth Date", value: model?.birthDateFormatted))
        }
        if model?.sex != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Sex", value: model?.sexValue))
        }
        if model?.issueDate != nil  {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Issue Date", value: model?.issueDateFormatted))
        }
        if model?.expiryDate != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Expiry Date", value: model?.expiryDateFormatted))
        }
        if model?.issuingAuthority != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Issuing Authority", value: model?.issuingAuthority))
        }
//        if model?.documentNumber != nil {
//            allIdGeetResults.append(IdCustomResultModelTest(title: "License Number", value: model?.documentNumber))
//        }
        if model?.residentCity != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Resident City", value: model?.residentCity))
        }
        if model?.residentState != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Resident State", value: model?.residentState))
        }
        if model?.residentPostalCode != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Resident Postal Code", value: model?.residentPostalCode))
        }
        if model?.nationality != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Nationality", value: model?.nationality))
        }
        if model?.birthPlace != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Birth Place", value: model?.birthPlace))
        }
        if model?.residentAddress != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Resident Address", value: model?.residentAddress))
        }
        if model?.residentCountry != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Resident Country", value: model?.residentCountry))
        }
        if model?.issuingCountry != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Issuing Country", value: model?.issuingCountry))
        }
        if model?.issuingJurisdiction != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Issuing Jurisdiction", value: model?.issuingJurisdiction))
        }
        if model?.administrativeNumber != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Administrative Number", value: model?.administrativeNumber))
        }
        if model?.portraitCaptureDate != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Portrait Capture Date", value: model?.portraitCaptureDate))
        }
        if model?.height != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Height", value: model?.height))
        }
        if model?.weight != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Weight", value: model?.weight))
        }
        if model?.eyeColor != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Eye Color", value: model?.eyeColor))
        }
        if model?.hairColor != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Hair Color", value: model?.hairColor))
        }
        if model?.ageInYears != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Age In Years", value: model?.ageInYears))
        }
        if model?.ageBirthYear != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Age Birth Years", value: model?.ageBirthYear))
        }
        if model?.documentNumber != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Document Number", value: model?.documentNumber))
        }

        if let drivingPrivileges = model?.drivingPrivileges {
            drivingPrivilegeResult.append(contentsOf: prepareDrivingPrivileges(drivingPrivileges: drivingPrivileges))
        }

        if model?.unDistinguishingSign != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "unDistinguishing Sign", value: model?.unDistinguishingSign))
        }
        if model?.ageOverNN != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Age Over NN", value: ((model?.ageOverNN != nil) ? "\(model?.ageOverNN ?? false)" : nil)))
        }
        if model?.ageOver18 != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Age Over 18", value: ((model?.ageOver18 != nil) ? "\(model?.ageOver18 ?? false)" : nil)))
        }
        if model?.ageOver21 != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Age Over 21", value: ((model?.ageOver21 != nil) ? "\(model?.ageOver21 ?? false)" : nil)))
        }
        if model?.biometricTemplateXX != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Biometric Template XX", value: model?.biometricTemplateXX))
        }
        if model?.familyNameNationalCharacter != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Family Name National Character", value: model?.familyNameNationalCharacter))
        }
        if model?.givenNameNationalCharacter != nil {
            allIdGeetResults.append(IdCustomResultModelTest(title: "Given Name National Character", value: model?.givenNameNationalCharacter))
        }
        return (allIdGeetResults, drivingPrivilegeResult)
    }

    static func prepareDrivingPrivileges(drivingPrivileges: [CredDrivingPrivilege]) -> [IdCustomResultModelTest] {
        var returnArray: [IdCustomResultModelTest] = []

        for drivingPrivilege in drivingPrivileges {
            let vehicleCategoryCode = drivingPrivilege.vehicleCategoryCode ?? ""
            returnArray.append(IdCustomResultModelTest(title: "Vehicle Category Code", value: vehicleCategoryCode))

            if let expiryDate = drivingPrivilege.expiryDate {
                returnArray.append(IdCustomResultModelTest(title: "Expiry Date \(vehicleCategoryCode)", value: expiryDate))
            }

            if let issueDate = drivingPrivilege.issueDate {
                returnArray.append(IdCustomResultModelTest(title: "Issue Date \(vehicleCategoryCode)", value: issueDate))
            }

            let codes = drivingPrivilege.codes
            for code in codes {
                if let code = code.code {
                    returnArray.append(IdCustomResultModelTest(title: "Code \(vehicleCategoryCode)", value: code))
                }
                if let sign = code.sign {
                    returnArray.append(IdCustomResultModelTest(title: "Sign \(vehicleCategoryCode)", value: sign))
                }
                if let value = code.value {
                    returnArray.append(IdCustomResultModelTest(title: "Value \(vehicleCategoryCode)", value: value))
                }
            }
        }
        return returnArray
    }
}
