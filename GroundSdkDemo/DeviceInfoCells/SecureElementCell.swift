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

class SecureElementCell: PeripheralProviderContentCell {

    @IBOutlet weak var signatureStatusLabel: UILabel!

    @IBOutlet weak var certificateURLLabel: UILabel!

    private var secureElement: Ref<SecureElement>?

    override func set(peripheralProvider provider: PeripheralProvider) {
        super.set(peripheralProvider: provider)
        secureElement = provider.getPeripheral(Peripherals.secureElement) {  [unowned self] secureElement in
            if let secureElement = secureElement {
                if let challengeRequestState = secureElement.challengeRequestState {
                    switch challengeRequestState {
                    case .processing:
                        self.signatureStatusLabel.text = "processing"
                    case .success(_, let token):
                        self.signatureStatusLabel.text = "success: \(token)"
                    case .failure:
                        self.signatureStatusLabel.text = "failed"
                    }
                } else {
                    self.signatureStatusLabel.text = "-"
                }

                self.certificateURLLabel.text = secureElement.certificateForImages?.absoluteURL != nil ?
                    secureElement.certificateForImages!.absoluteString : "-"
                self.show()
            } else {
                self.hide()
            }
        }
    }

    @IBAction func signAction(_ sender: Any) {
        if let secureElement = secureElement?.value {
            _ = secureElement.sign(challenge: "fakeChallenge", with: .associate)
        }
    }
}
