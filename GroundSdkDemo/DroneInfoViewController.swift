// Copyright (C) 2019 Parrot Drones SAS
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

class DroneInfoViewController: DeviceInfoViewController<Drone> {

    private var drone: Drone? {
        provider
    }

    private let copterHudSegue = "CopterHudSegue"

    override func viewDidLoad() {
        super.viewDidLoad()

        if let droneUid = deviceUid {
            provider = groundSdk.getDrone(uid: droneUid) { [weak self] _ in
                _ = self?.navigationController?.popViewController(animated: true)
            }
        }
        // get the drone
        if let drone = provider {
            // header
            modelLabel.text = drone.model.description
            nameRef = drone.getName { [unowned self] name in
                self.title = name!
            }
            stateRef = drone.getState { [unowned self] state in
                // state is never nil
                self.setState(state!)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        GamepadController.sharedInstance.droneUid = deviceUid
    }

    override func viewWillDisappear(_ animated: Bool) {
        GamepadController.sharedInstance.droneUid = nil

        super.viewWillDisappear(animated)
    }

    @IBAction override func forget(_ sender: UIButton) {
        _ = drone?.forget()
    }

    @IBAction override func connectDisconnect(_ sender: UIButton) {
        if let connectionState = stateRef?.value?.connectionState {
            if connectionState == DeviceState.ConnectionState.disconnected {
                if let drone = drone {
                    if drone.state.connectors.count > 1 {
                        let alert = UIAlertController(title: "Connect using", message: "", preferredStyle: .actionSheet)
                        if let popoverController = alert.popoverPresentationController {
                            popoverController.sourceView = sender
                            popoverController.sourceRect = sender.bounds
                        }
                        for connector in drone.state.connectors {
                            alert.addAction(
                                UIAlertAction(title: connector.description, style: .default) { [unowned self] _ in
                                    self.connect(drone: drone, connector: connector) })
                        }
                        present(alert, animated: true, completion: nil)
                    } else if drone.state.connectors.count == 1 {
                        connect(drone: drone, connector: drone.state.connectors[0])
                    }
                }
            } else {
                _ = drone?.disconnect()
            }
        }
    }

    @IBAction func showHud(_ sender: UIButton) {
        if let drone = drone {
            if drone.getPilotingItf(PilotingItfs.manualCopter) != nil {
                performSegue(withIdentifier: copterHudSegue, sender: self)
            }
        }
    }

    private func connect(drone: Drone, connector: DeviceConnector) {
        if drone.state.connectionStateCause == .badPassword {
            // ask for password
            let alert = UIAlertController(title: "Password", message: "", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                if let password = alert.textFields?[0].text {
                    _ = drone.connect(connector: connector, password: password)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            _ = drone.connect(connector: connector)
        }
    }
}
