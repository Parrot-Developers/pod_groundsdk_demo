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

class ObstacleAvoidanceCell: PeripheralProviderContentCell {
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var preferredModeButton: UISegmentedControl!
    private var obstacleAvoidance: Ref<ObstacleAvoidance>?

    private var preferredModeSet: [Int: String] = [:]

    override func set(peripheralProvider provider: PeripheralProvider) {
        super.set(peripheralProvider: provider)
        obstacleAvoidance = provider.getPeripheral(Peripherals.obstacleAvoidance) {  [unowned self] obstacleAvoidance in
            if let obstacleAvoidance = obstacleAvoidance {
                if preferredModeSet.isEmpty {
                    preferredModeButton.removeAllSegments()
                    for mode in ObstacleAvoidanceMode.allCases {
                        preferredModeSet[preferredModeButton.numberOfSegments] = mode.description
                        preferredModeButton.insertSegment(withTitle: mode.description,
                                                          at: preferredModeButton.numberOfSegments,
                                                          animated: false)
                        if mode == obstacleAvoidance.mode.preferredValue {
                            preferredModeButton.selectedSegmentIndex = preferredModeButton.numberOfSegments - 1
                        }
                    }
                }
                self.stateLabel.text = obstacleAvoidance.state.description
                self.show()
            } else {
                self.hide()
            }
        }
    }

    @IBAction func changePreferredValue(_ sender: Any) {
        if let obstacleAvoidance = obstacleAvoidance?.value {
            let newPreferredMode = preferredModeSet[preferredModeButton.selectedSegmentIndex]
            for mode in ObstacleAvoidanceMode.allCases
            where mode.description == newPreferredMode {
                obstacleAvoidance.mode.preferredValue = mode
                    return
            }
        }
    }
}
