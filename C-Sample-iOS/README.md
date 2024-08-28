# iOS Tap2iD Verify SDK Sample App


Welcome to the iOS Tap2iD Verify SDK Sample App! This repository contains a sample iOS application built using Swift. Below you will find detailed information about the project, how to get started, and other relevant details.

## Table of Contents
- [Introduction](#introduction)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)
- [Contact](#contact)

## Introduction
This sample app demonstrates how to integrate and use the Tap2iD Verify SDK for iOS to perform identity verification using ISO 18013-5 Mobile Driver's License (mDL).

## Features
- **Scan QR Code:** Scan a QR code from an mDL holder app.
- **Verify mDL License:** Verify the mDL license to ensure its authenticity.
- **Display Results:** Show all the state information on a result screen.
- **Result Object/Error Object:** At the end of the process, display either the result object or an error object based on the verification outcome.

## Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.0+
- iPhone 12+

## Installation
To get started with the project, follow these steps:

1. Clone the repository:
    ```sh
    
    git clone https://github.com/CredenceID/C-Sample-iOS.git
    ```
2. Navigate to the project directory:
    ```sh
    
    cd C-Sample-iOS
    ```
3. Open the project in Xcode:
    ```sh
    
    open C-Sample-iOS.xcodeproj
    ```
4. Install dependencies :
    - **Using Swift Package Manager:**
      - In Xcode, select “File” → “Add Packages…”
      - Enter the URL: [https://github.com/CredenceID/Tap2iD-VerifierSDK-Swift.git](https://github.com/CredenceID/Tap2iD-VerifierSDK-Swift.git)
      - Alternatively, you can add the following dependency to your `Package.swift`:
        ```swift
        .package(url: "https://github.com/CredenceID/Tap2iD-VerifierSDK-Swift.git", from: "0.0.7")
        ```
5. Build and run the project in Xcode.

## Usage
To use the app, follow these steps:

1. **Grant Permissions:** Allow all required permissions, including camera and Bluetooth (BLE), to ensure the app functions properly.
2. **Open QR Code Scanner:** Tap the "QR Code" button on the main screen to open the camera interface.
3. **Scan QR Code:** Use the camera to scan a QR code from an mDL holder application.
4. **Wait for Result:** The app will process the scanned QR code, verify the mDL license, and display the results on the result screen. Wait for the verification result to be displayed.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contact
For any questions or suggestions, feel free to contact:

- Your Name - [deepraj.jadhav@credenceid.com](mailto:deepraj.jadhav@credenceid.com)
- Project Link: [https://github.com/CredenceID/C-Sample-iOS](https://github.com/CredenceID/C-Sample-iOS)

---

Thank you for checking out the iOS Swift Sample Project! Happy coding!
