// Copyright (C) 2022 Parrot Drones SAS
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

class DeveloperModeViewController: UITableViewController, DeviceViewController {

    private let groundSdk = GroundSdk()
    private var droneUid: String?
    private var debugShellRef: Ref<DebugShell>?
    private var networkControlRef: Ref<NetworkControl>?
    @IBOutlet private weak var debugShellStateLabel: UILabel!
    @IBOutlet private weak var directConnectionModeLabel: UILabel!

    func setDeviceUid(_ uid: String) {
        droneUid = uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let drone = groundSdk.getDrone(uid: droneUid!) else {
            return
        }
        debugShellRef = drone
            .getPeripheral(Peripherals.debugShell) { [weak self] debugShell in
                guard let debugShell = debugShell, let `self` = self else {
                    self?.performSegue(withIdentifier: "exit", sender: self)
                    return
                }
                self.debugShellStateLabel.text = debugShell.state.value.description
            }
        networkControlRef = drone.getPeripheral(Peripherals.networkControl) { [weak self] networkControl in
            guard let networkControl = networkControl, let `self` = self else {
                self?.performSegue(withIdentifier: "exit", sender: self)
                return
            }
            self.directConnectionModeLabel.text = networkControl.directConnection.mode.description
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell,
              let identifier = cell.reuseIdentifier,
              let networkControl = networkControlRef?.value else {
            return
        }
        switch identifier {
        case "directConnectionMode":
            let target = segue.destination as! ChooseEnumViewController
            target.initialize(data: ChooseEnumViewController.Data(
                dataSource: [NetworkDirectConnectionMode](networkControl.directConnection.supportedModes),
                selectedValue: networkControl.directConnection.mode.description,
                itemDidSelect: { value in
                    networkControl.directConnection.mode = value as! NetworkDirectConnectionMode
                }
            ))
        case "debugShell":
            (segue.destination as! DebugShellViewController)
                .setDeviceUid(droneUid!)
        default:
            break
        }
    }
}
