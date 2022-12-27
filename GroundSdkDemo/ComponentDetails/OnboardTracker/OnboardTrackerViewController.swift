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

class OnboardTrackerViewController: UITableViewController, DeviceViewController {
    private let groundSdk = GroundSdk()
    private var droneUid: String?
    private var onboardTrackerRef: Ref<OnboardTracker>?
    private var onboardTracker: OnboardTracker?
    private var arrayKey = [UInt]()

    private let hudSegue = "hudSegue"

    func setDeviceUid(_ uid: String) {
        droneUid = uid
    }

    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "targetCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "functionCell")
        super.viewDidLoad()
        if let drone = groundSdk.getDrone(uid: droneUid!) {
            onboardTrackerRef = drone.getPeripheral(Peripherals.onboardTracker) { [weak self] onboardTracker in
                guard let self = self else { return }
                self.onboardTracker = onboardTracker
                if let onboardTracker = onboardTracker {
                    self.arrayKey.removeAll()
                    for trackingObj in onboardTracker.targets {
                        self.arrayKey.append(trackingObj.key)
                    }
                    self.tableView.reloadData()
                } else {
                    self.performSegue(withIdentifier: "exit", sender: self)
                }
            }
        }
    }

    // MARK: - User Commands
    @IBAction func removeAll(_ sender: Any) {
        onboardTracker?.removeAllTargets()
    }

     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
        let cell = tableView.dequeueReusableCell(withIdentifier: "functionCell", for: indexPath)
        cell.textLabel?.text = "Remove all targets"
            return cell
        default:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "targetCell")
            cell.textLabel?.text = "id : \(String(describing: self.arrayKey[indexPath.row]))"
            switch onboardTracker?.targets[self.arrayKey[indexPath.row]]?.state {
            case .lost:
                cell.detailTextLabel?.text = "searching"
            case .tracked:
                cell.detailTextLabel?.text = "tracking"
            case .none:
                cell.detailTextLabel?.text = "none"
            }
            return cell
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        default: return onboardTracker?.targets.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: onboardTracker?.removeAllTargets()
        default: return
        }
    }

    @IBAction func showHud(_ sender: UIButton) {
        self.performSegue(withIdentifier: hudSegue, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == hudSegue, let droneUid = droneUid {
            if let destVC = segue.destination as? OnboardTrackerHudViewController {
                destVC.setDeviceUid(droneUid)
            }
        }
    }

}
