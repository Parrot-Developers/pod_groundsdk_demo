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

class NetworkControlViewController: UITableViewController, DeviceViewController {

    private let groundSdk = GroundSdk()
    private var droneUid: String?
    private var networkControl: Ref<NetworkControl>?
    @IBOutlet weak var routingPolicy: UILabel!
    @IBOutlet weak var maxCellularBitrate: NumSettingView!
    @IBOutlet weak var directConnectionMode: UILabel!

    func setDeviceUid(_ uid: String) {
        droneUid = uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let drone = groundSdk.getDrone(uid: droneUid!) {
            networkControl = drone.getPeripheral(Peripherals.networkControl) { [weak self] networkControl in
                if let networkControl = networkControl, let `self` = self {
                    self.routingPolicy.text = networkControl.routingPolicy.policy.description
                    self.maxCellularBitrate.updateWith(intSetting: networkControl.maxCellularBitrate)
                    self.directConnectionMode.text = networkControl.directConnection.mode.description
                } else {
                    self?.performSegue(withIdentifier: "exit", sender: self)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell,
           let reuseIdentifier = cell.reuseIdentifier,
           let networkControl = networkControl?.value,
           let target = segue.destination as? ChooseEnumViewController {
            switch reuseIdentifier {
            case "routingPolicy":
                target.initialize(data: ChooseEnumViewController.Data(
                    dataSource: [NetworkControlRoutingPolicy](networkControl.routingPolicy.supportedPolicies),
                    selectedValue: networkControl.routingPolicy.policy.description,
                    itemDidSelect: { [unowned self] value in
                        self.networkControl?.value?.routingPolicy.policy = value as! NetworkControlRoutingPolicy
                    }
                ))
            case "directConnectionMode":
                target.initialize(data: ChooseEnumViewController.Data(
                    dataSource: [NetworkDirectConnectionMode](networkControl.directConnection.supportedModes),
                    selectedValue: networkControl.directConnection.mode.description,
                    itemDidSelect: { [unowned self] value in
                        self.networkControl?.value?.directConnection.mode = value as! NetworkDirectConnectionMode
                    }
                ))
            default:
                return
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let reuseIdentifier = cell?.reuseIdentifier {
            let segueIdentifier: String
            switch reuseIdentifier {
            case "routingPolicy", "directConnectionMode":
                segueIdentifier = "selectEnumValue"
            default:
                return
            }
            performSegue(withIdentifier: segueIdentifier, sender: cell)
        }
    }

    @IBAction func maxCellularBitrateDidChange(_ sender: NumSettingView) {
        networkControl?.value?.maxCellularBitrate.value = Int(sender.value)
    }
}

private extension UITableView {
    func enable(section: Int, on: Bool) {
        for cellIndex in 0..<numberOfRows(inSection: section) {
            cellForRow(at: IndexPath(item: cellIndex, section: section))?.enable(on: on)
        }
    }
}

private extension UITableViewCell {
    func enable(on: Bool) {
        for view in contentView.subviews {
            view.isUserInteractionEnabled = on
            view.alpha = on ? 1 : 0.5
        }
    }
}
