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

class CellularCell: PeripheralProviderContentCell {

    private var cellular: Ref<Cellular>?

    @IBOutlet weak var modemStatusLabel: UILabel!
    @IBOutlet weak var imeiLabel: UILabel!
    @IBOutlet weak var simStatusLabel: UILabel!
    @IBOutlet weak var simIccidLabel: UILabel!
    @IBOutlet weak var simImsiLabel: UILabel!
    @IBOutlet weak var registrationStatusLabel: UILabel!
    @IBOutlet weak var networkStatusLabel: UILabel!
    @IBOutlet weak var operatorLabel: UILabel!
    @IBOutlet weak var technologyLabel: UILabel!
    @IBOutlet weak var isRoamingAllowedLabel: UILabel!
    @IBOutlet weak var isPinCodeRequestedLabel: UILabel!
    @IBOutlet weak var pinRemainingTriesLabel: UILabel!

    override func set(peripheralProvider provider: PeripheralProvider) {
        super.set(peripheralProvider: provider)
        cellular = provider.getPeripheral(Peripherals.cellular) { [unowned self] cellular in
            if let cellular = cellular {
                self.modemStatusLabel.text = "\(cellular.modemStatus.description)"
                self.imeiLabel.text = "\(cellular.imei)"
                self.simStatusLabel.text = "\(cellular.simStatus.description)"
                self.simIccidLabel.text = "\(cellular.simIccid)"
                self.simImsiLabel.text = "\(cellular.simImsi)"
                self.registrationStatusLabel.text = "\(cellular.registrationStatus.description)"
                self.networkStatusLabel.text = "\(cellular.networkStatus.description)"
                self.operatorLabel.text = "\(cellular.operator)"
                self.technologyLabel.text = "\(cellular.technology.description)"
                self.isRoamingAllowedLabel.text = cellular.isRoamingAllowed.value ? "yes" : "no"
                self.isPinCodeRequestedLabel.text = cellular.isPinCodeRequested ? "yes" : "no"
                self.pinRemainingTriesLabel.text = "\(cellular.pinRemainingTries)"
                self.show()
            } else {
                self.hide()
            }
        }
    }
}
