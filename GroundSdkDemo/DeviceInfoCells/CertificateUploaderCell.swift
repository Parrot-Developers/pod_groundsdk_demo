// Copyright (C) 2020 Parrot Drones SAS
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions
//    are met:
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in
//      the documentation and/or other materials provided with the
//      distribution.
//    * Neither the name of the Parrot Company nor the names
//      of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written
//      permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
//    PARROT COMPANY BE LIABLE FOR ANY DIRECT, INDIRECT,
//    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
//    OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
//    AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
//    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
//    SUCH DAMAGE.

import UIKit
import GroundSdk
import MobileCoreServices

class CertificateUploaderCell: PeripheralProviderContentCell {

    @IBOutlet weak var state: UILabel!
    private var certificateUploader: Ref<CertificateUploader>?

    override func set(peripheralProvider provider: PeripheralProvider) {
        super.set(peripheralProvider: provider)
        certificateUploader = provider.getPeripheral(
            Peripherals.certificateUploader) { [unowned self] certificateUploader in
            if let certificateUploader = certificateUploader {
                state.text = certificateUploader.state?.description ?? "-"
                self.show()
            } else {
                self.hide()
            }
        }
    }

    @IBAction func uploadAction(_ sender: Any) {
        let importMenu = UIDocumentPickerViewController(documentTypes: [kUTTypeItem as String], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.window?.rootViewController?.present(importMenu, animated: true, completion: nil)
    }

    @IBAction func fetchSignature(_ sender: Any) {
        certificateUploader?.value?.fetchSignature(completion: { signature in
            let alert = UIAlertController(title: "Signature", message: signature, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true)
        })
    }

    @IBAction func fetchInfo(_ sender: Any) {
        certificateUploader?.value?.fetchInfo(completion: { info in
            let message = """
                Debug features: \(info?.debugFeatures.joined(separator: ", ") ?? "-")
                Premium features: \(info?.premiumFeatures.joined(separator: ", ") ?? "-")
                """
            let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true)
        })
    }
}

extension CertificateUploaderCell: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        if let certificateUploader = certificateUploader?.value {
            _ = certificateUploader.upload(certificate: myURL.path)
        }
    }
}
