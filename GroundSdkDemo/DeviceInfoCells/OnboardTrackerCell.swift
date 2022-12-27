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

class OnboardTrackerCell: PeripheralProviderContentCell {

    @IBOutlet private weak var trackingListCountValue: UILabel!
    @IBOutlet private weak var trackingAvailabilityValue: UILabel!
    @IBOutlet private weak var activationTrackingEngine: UIButton!
    @IBOutlet private weak var deactivationTrackingEngine: UIButton!
    @IBOutlet private weak var stateTrackingEngine: UILabel!
    @IBOutlet private weak var switchBoxProposals: UISwitch!

    private var onboardTrackerRef: Ref<OnboardTracker>?

    override func set(peripheralProvider provider: PeripheralProvider) {
        super.set(peripheralProvider: provider)

        onboardTrackerRef = provider.getPeripheral(Peripherals.onboardTracker) { [unowned self] onboardTracker in
            if let onboardTracker = onboardTracker {
                self.trackingListCountValue.text = "\(onboardTracker.targets.count)"
                self.trackingAvailabilityValue.text = onboardTracker.isAvailable ?
                    "Available" : "Not Available"
                self.activationTrackingEngine.isHidden = onboardTracker.trackingEngineState != .available
                self.deactivationTrackingEngine.isHidden = onboardTracker.trackingEngineState != .activated
                self.stateTrackingEngine.text = onboardTracker.trackingEngineState.description
                self.show()
            } else {
                self.hide()
            }
        }
    }

    @IBAction private func startBoxProposal(_ sender: UIButton) {
        self.onboardTrackerRef?.value?.startTrackingEngine(boxProposals: switchBoxProposals.isOn)
    }

    @IBAction private func stopTrackingEngine(_ sender: UIButton) {
        self.onboardTrackerRef?.value?.stopTrackingEngine()
    }
}
