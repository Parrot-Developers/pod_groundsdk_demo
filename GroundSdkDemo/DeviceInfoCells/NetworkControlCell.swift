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

class NetworkControlCell: PeripheralProviderContentCell {

    private var networkControl: Ref<NetworkControl>?

    @IBOutlet weak var routingPolicyLabel: UILabel!
    @IBOutlet weak var currentLinkLabel: UILabel!
    @IBOutlet weak var linkQualityLabel: UILabel!
    @IBOutlet weak var linksLabel: UILabel!
    @IBOutlet weak var maxCellularBitrateLabel: UILabel!
    @IBOutlet weak var directConnectionModeLabel: UILabel!

    override func set(peripheralProvider provider: PeripheralProvider) {
        super.set(peripheralProvider: provider)
        networkControl = provider.getPeripheral(Peripherals.networkControl) {  [unowned self] networkControl in
            if let networkControl = networkControl {
                self.routingPolicyLabel.text = networkControl.routingPolicy.policy.description
                self.currentLinkLabel.text = networkControl.currentLink?.description ?? "-"
                self.linkQualityLabel.text = networkControl.linkQuality?.description ?? "-"
                if networkControl.links.isEmpty {
                    self.linksLabel.text = "-"
                } else {
                    self.linksLabel.text = networkControl.links.map { $0.debugDescription }.joined(separator: ", ")
                }
                self.maxCellularBitrateLabel.text = networkControl.maxCellularBitrate.displayString
                self.directConnectionModeLabel.text = networkControl.directConnection.mode.description
                self.show()
            } else {
                self.hide()
            }
        }
    }
}
