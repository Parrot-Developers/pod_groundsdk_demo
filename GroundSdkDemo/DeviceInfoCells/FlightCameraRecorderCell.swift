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

class FlightCameraRecorderCell: PeripheralProviderContentCell {

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!

    private var flightCameraRecorder: Ref<FlightCameraRecorder>?

    override func set(peripheralProvider provider: PeripheralProvider) {
        super.set(peripheralProvider: provider)
        flightCameraRecorder = provider.getPeripheral(Peripherals.flightCameraRecorder) { [unowned self] fcr in
            if let flightCameraRecorder = fcr {
                if flightCameraRecorder.activePipelines.value.isEmpty {
                    self.switchLabel.text = "disabled"
                    self.startStopButton.setTitle("Enable", for: .normal)
                } else {
                    self.switchLabel.text = "enabled"
                    self.startStopButton.setTitle("Disable", for: .normal)
                }
                self.show()
            } else {
                self.hide()
            }
        }
    }

    @IBAction func activateOrDeactivaAction(_ sender: Any) {
        if let flightCameraRecorder = flightCameraRecorder?.value {
            if flightCameraRecorder.activePipelines.value.isEmpty {
                // Activate all supported
                flightCameraRecorder.activePipelines.value = flightCameraRecorder.activePipelines.supportedValues
            } else {
                // Deactivate all
                flightCameraRecorder.activePipelines.value = []
            }
        }
    }

}
